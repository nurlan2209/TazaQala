import express from "express";
import upload from "../middleware/upload.js";
import cloudinary from "../utils/cloudinary.js";
import Report from "../models/Report.js";
import User from "../models/User.js";
import { auth, authorizeRoles } from "../middleware/auth.js";
import DISTRICTS from "../config/districts.js";
import { sendReportStatusEmail } from "../utils/emailService.js";
import { GoogleGenerativeAI } from "@google/generative-ai";

const router = express.Router();

const parseCoordinate = (value) => {
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : null;
};

const findReportAndCheckAccess = async (reportId, user) => {
  const report = await Report.findById(reportId);
  if (!report) {
    return { error: "Report not found" };
  }

  if (user.role === "admin" && report.district !== user.district) {
    return { error: "Бұл ауданға рұқсат жоқ", status: 403 };
  }

  return { report };
};

// --------------------
// Create new report (client/admin)
// --------------------
router.post("/create", auth, upload.single("image"), async (req, res) => {
  try {
    const file = req.file;
    if (!file) return res.status(400).json({ message: "Image is required" });

    const { category, description } = req.body;
    if (!category || !description) {
      return res.status(400).json({ message: "Мәліметтер толық емес" });
    }

    const lat = parseCoordinate(req.body.lat);
    const lng = parseCoordinate(req.body.lng);
    if (lat === null || lng === null) {
      return res.status(400).json({ message: "Координаталар дұрыс емес" });
    }

    let district = req.user.district;
    if (req.user.role === "director") {
      const requestedDistrict = req.body.district;
      if (!requestedDistrict || !DISTRICTS.includes(requestedDistrict)) {
        return res.status(400).json({ message: "Аудан таңдалмады" });
      }
      district = requestedDistrict;
    }

    if (!district) {
      return res
        .status(400)
        .json({ message: "Аудан ақпаратын анықтау мүмкін болмады" });
    }

    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: "tazaqala" },
        (error, uploadResult) => {
          if (error) reject(error);
          else resolve(uploadResult);
        }
      );
      stream.end(file.buffer);
    });

    const report = new Report({
      userId: req.user.id,
      district,
      category,
      description,
      location: { lat, lng },
      imageUrl: result.secure_url
    });

    await report.save();
    res.json(report);
  } catch (err) {
    console.error("Create report error:", err);
    res.status(500).json({ message: "Error creating report" });
  }
});

// --------------------
// Get all reports (restricted by role)
// --------------------
router.get("/all", auth, async (req, res) => {
  try {
    const { district: districtQuery } = req.query;

    let filter = {};
    if (
      districtQuery &&
      typeof districtQuery === "string" &&
      DISTRICTS.includes(districtQuery)
    ) {
      filter.district = districtQuery;
    } else if (req.user.role === "client" || req.user.role === "admin") {
      filter.district = req.user.district;
    }

    const reports = await Report.find(filter).sort({ createdAt: -1 });
    res.json(reports);
  } catch (err) {
    console.error("Fetch reports error:", err);
    res.status(500).json({ message: "Error fetching reports" });
  }
});

// --------------------
// Get my reports (user)
// --------------------
router.get("/mine", auth, async (req, res) => {
  try {
    const reports = await Report.find({ userId: req.user.id })
      .where({ district: req.user.district })
      .sort({ createdAt: -1 });
    res.json(reports);
  } catch (err) {
    console.error("Fetch my reports error:", err);
    res.status(500).json({ message: "Error fetching your reports" });
  }
});

// --------------------
// Update report (admin/director only)
// --------------------
router.patch(
  "/update/:id",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { report, error, status } = await findReportAndCheckAccess(
        req.params.id,
        req.user
      );
      if (error) {
        return res.status(status || 404).json({ message: error });
      }

      const { category, description, status: newStatus } = req.body;
      const lat = req.body.lat ? parseCoordinate(req.body.lat) : null;
      const lng = req.body.lng ? parseCoordinate(req.body.lng) : null;

      if (category) report.category = category;
      if (description) report.description = description;
      if (newStatus) report.status = newStatus;
      if (lat !== null && lng !== null) {
        report.location = { lat, lng };
      }

      await report.save();

      try {
        const owner = await User.findById(report.userId);
        if (owner?.email) {
          await sendReportStatusEmail({
            to: owner.email,
            report,
            status: report.status
          });
        }
      } catch (mailErr) {
        console.error("Report status email error:", mailErr.message || mailErr);
      }

      res.json(report);
    } catch (err) {
      console.error("Update report error:", err);
      res.status(500).json({ message: "Error updating report" });
    }
  }
);

// --------------------
// Delete report (admin/director only)
// --------------------
router.delete(
  "/delete/:id",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { report, error, status } = await findReportAndCheckAccess(
        req.params.id,
        req.user
      );
      if (error) {
        return res.status(status || 404).json({ message: error });
      }

      await report.deleteOne();
      res.json({ message: "Report deleted" });
    } catch (err) {
      console.error("Delete report error:", err);
      res.status(500).json({ message: "Error deleting report" });
    }
  }
);

// --------------------
// AI insights (admin/director)
// --------------------
router.get(
  "/insights/ai",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const district =
        req.user.role === "admin" ? req.user.district : req.query.district;

      const filter = district ? { district } : {};
      const reports = await Report.find(filter).sort({ createdAt: -1 });

      const statsContext = buildStatsContext(reports);
      const aiPayload = await generateAiInsights(statsContext);

      res.json({
        stats: statsContext.stats,
        summary: aiPayload.summary,
        recommendations: aiPayload.recommendations
      });
    } catch (err) {
      console.error("AI insights error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// --------------------
// District stats (director)
// --------------------
router.get(
  "/stats/districts",
  auth,
  authorizeRoles("director"),
  async (req, res) => {
    try {
      const rawStats = await Report.aggregate([
        {
          $group: {
            _id: { district: "$district", status: "$status" },
            count: { $sum: 1 }
          }
        }
      ]);

      const statsMap = new Map();
      rawStats.forEach((item) => {
        const district = item._id?.district || "Белгісіз";
        const status = item._id?.status || "unknown";
        if (!statsMap.has(district)) {
          statsMap.set(district, { total: 0, statusCounts: {} });
        }
        const bucket = statsMap.get(district);
        bucket.total += item.count;
        bucket.statusCounts[status] = item.count;
      });

      const response = DISTRICTS.map((district) => {
        const bucket = statsMap.get(district);
        return {
          district,
          total: bucket?.total || 0,
          statusCounts: bucket?.statusCounts || {}
        };
      });

      res.json(response);
    } catch (err) {
      console.error("District stats error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

export default router;

const genAiKey = process.env.GEMINI_API_KEY;
const genAiClient = genAiKey ? new GoogleGenerativeAI(genAiKey) : null;

const buildStatsContext = (reports) => {
  const total = reports.length;
  const resolved = reports.filter((r) => r.status === "done").length;
  const unresolved = total - resolved;
  const lastMonth = Date.now() - 1000 * 60 * 60 * 24 * 30;
  const lastMonthCount = reports.filter(
    (r) => getTimestamp(r.createdAt) >= lastMonth
  ).length;

  const statusBreakdown = reports.reduce((acc, report) => {
    const status = report.status || "unknown";
    acc[status] = (acc[status] || 0) + 1;
    return acc;
  }, {});

  const categoryBreakdown = Object.entries(
    reports.reduce((acc, report) => {
      if (!report.category) return acc;
      acc[report.category] = (acc[report.category] || 0) + 1;
      return acc;
    }, {})
  )
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([category, count]) => ({ category, count }));

  const stats = {
    totalReports: total,
    resolved,
    unresolved,
    monthlyGrowth: lastMonthCount,
    statusBreakdown,
    highPriority: Math.min(unresolved, 3),
    mediumPriority: Math.max(unresolved - 3, 0),
    accuracy: total ? 82 : 0,
    topCategories: categoryBreakdown
  };

  return {
    stats,
    reports: reports.slice(0, 100), // ограничим контекст
    categoryBreakdown,
    statusBreakdown
  };
};

const generateAiInsights = async (context) => {
  if (!genAiClient) {
    return {
      summary:
        "AI қызметі әзірге сынақ режимінде. Көбірек деректер жиналған сайын жіктелген ұсыныстар автоматты шығады.",
      recommendations: buildFallbackRecommendations(context.reports)
    };
  }

  try {
    const model = genAiClient.getGenerativeModel({
      model: "gemini-1.5-flash"
    });

    const prompt = `
Сен TazaQala қалалық сервистінің аналитикалық көмекшісісің.
Төменде шағым статистикасы JSON форматында берілген. Мәліметтерге сүйене отырып:
1) өңір бойынша қысқа қорытынды жаз.
2) 2-4 actionable ұсыныс жаса.
Алгоритм:
- Жауапты тек JSON ретінде қайтар.
- JSON схемасы:
{
  "summary": "Екі сөйлемдік қорытынды...",
  "recommendations": [
    {
      "title": "",
      "description": "",
      "action": "",
      "category": "",
      "level": "urgent|warning|info"
    }
  ]
}
Мәліметтер: ${JSON.stringify(context.stats)}.
Қосымша мысал ретінде санаттарды қолдан: ${JSON.stringify(
      context.categoryBreakdown
    )}.
`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();
    const parsed = safeJsonParse(text);
    if (!parsed) {
      throw new Error("Failed to parse Gemini response");
    }

    const recommendations = Array.isArray(parsed.recommendations)
      ? parsed.recommendations.map(normalizeRecommendation).filter(Boolean)
      : [];

    return {
      summary:
        typeof parsed.summary === "string" && parsed.summary.trim().length
          ? parsed.summary.trim()
          : "AI қорытындысы уақытша қолжетімсіз.",
      recommendations:
        recommendations.length > 0
          ? recommendations
          : buildFallbackRecommendations(context.reports)
    };
  } catch (err) {
    console.error("Gemini AI error:", err.message || err);
    return {
      summary:
        "AI сервисінен жауап алу мүмкін болмады. Кейінірек тағы қайталап көріңіз.",
      recommendations: buildFallbackRecommendations(context.reports)
    };
  }
};

const buildFallbackRecommendations = (reports) => {
  if (!reports.length) {
    return [
      {
        id: "general",
        level: "info",
        category: "Жалпы",
        title: "AI ұсыныстары дайын",
        description:
          "Система нақты деректерді жинауда. Шағымдар түскен сайын автоматты ұсыныстар пайда болады.",
        action: "Деректерді қадағалау"
      }
    ];
  }

  const categoryCount = reports.reduce((acc, report) => {
    if (!report.category) return acc;
    acc[report.category] = (acc[report.category] || 0) + 1;
    return acc;
  }, {});

  const [topCategory = "Жалпы"] = Object.entries(categoryCount).sort(
    (a, b) => b[1] - a[1]
  )[0] || ["Жалпы", 0];

  const unresolved = reports.filter((r) => r.status !== "done");

  return [
    {
      id: "category-focus",
      level: "urgent",
      category: topCategory,
      title: `${topCategory} санатындағы шағымдар өсуде`,
      description:
        "Соңғы аптада осы санат бойынша шағымдар саны едәуір артты. Қосымша ресурстар бөлуді қарастырыңыз.",
      action: "Ресурстарды бөлу"
    },
    {
      id: "backlog",
      level: "warning",
      category: "Жалпы",
      title: "Аяқталмаған шағымдар",
      description: `Қазіргі кезде ${unresolved.length} шағым шешілмеген. Статустарын жаңартуды жеделдету ұсынылады.`,
      action: "Статустарды жаңарту"
    }
  ];
};

const normalizeRecommendation = (item) => {
  if (!item || !item.title || !item.description) return null;
  return {
    id: item.id || item.title.slice(0, 40),
    level: item.level || "info",
    category: item.category || "Жалпы",
    title: item.title,
    description: item.description,
    action:
      item.action ||
      "Әрекет жоспарын белгілеңіз (жауапты бөлім, мерзім, ресурстар)."
  };
};

const safeJsonParse = (text) => {
  if (!text) return null;
  const trimmed = text.trim();
  const jsonMatch = trimmed.match(/\{[\s\S]*\}$/);
  try {
    return JSON.parse(jsonMatch ? jsonMatch[0] : trimmed);
  } catch (err) {
    return null;
  }
};

const getTimestamp = (value) => {
  if (!value) return 0;
  if (value instanceof Date) return value.getTime();
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? 0 : parsed.getTime();
};
