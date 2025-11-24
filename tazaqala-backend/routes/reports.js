import express from "express";
import upload from "../middleware/upload.js";
import cloudinary from "../utils/cloudinary.js";
import Report from "../models/report.js";
import User from "../models/User.js";
import { auth, authorizeRoles } from "../middleware/auth.js";
import { sendReportStatusEmail } from "../utils/emailService.js";

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

  if (user.role === "staff") {
    if (!report.assignedTo || report.assignedTo.toString() !== user.id) {
      return { error: "Бұл есеп сізге бекітілмеген", status: 403 };
    }
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
      category,
      description,
      location: { lat, lng },
      imageUrl: result.secure_url,
      assignedTo: null
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
    let filter = {};
    if (req.user.role === "staff") {
      filter.assignedTo = req.user.id;
    } else if (req.user.role === "client") {
      filter.userId = req.user.id;
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
    const reports = await Report.find({ userId: req.user.id }).sort({
      createdAt: -1
    });
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
  authorizeRoles("admin", "staff"),
  async (req, res) => {
    try {
      const { report, error, status } = await findReportAndCheckAccess(
        req.params.id,
        req.user
      );
      if (error) {
        return res.status(status || 404).json({ message: error });
      }

      const { category, description, status: newStatus, assignedTo } = req.body;
      const lat = req.body.lat ? parseCoordinate(req.body.lat) : null;
      const lng = req.body.lng ? parseCoordinate(req.body.lng) : null;

      if (category) report.category = category;
      if (description) report.description = description;
      if (newStatus) report.status = newStatus;
      if (req.user.role === "admin" && assignedTo) {
        const staffUser = await User.findById(assignedTo);
        if (!staffUser || staffUser.role !== "staff") {
          return res.status(400).json({ message: "Қате қызметкер" });
        }
        report.assignedTo = assignedTo;
      }
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
  authorizeRoles("admin"),
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


export default router;
