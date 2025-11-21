import express from "express";
import upload from "../middleware/upload.js";
import cloudinary from "../utils/cloudinary.js";
import Report from "../models/Report.js";
import { auth, isAdmin } from "../middleware/authMiddleware.js";

const router = express.Router();

// --------------------
// Create new report (user)
// --------------------
router.post("/create", auth, upload.single("image"), async (req, res) => {
  try {
    const file = req.file;
    if (!file) return res.status(400).json({ message: "Image is required" });

    // Upload to Cloudinary
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: "tazaqala" },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(file.buffer);
    });

    const report = new Report({
      userId: req.user.id,
      category: req.body.category,
      description: req.body.description,
      location: {
        lat: req.body.lat,
        lng: req.body.lng,
      },
      imageUrl: result.secure_url,
      status: "new", // default
    });

    await report.save();
    res.json(report);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error creating report" });
  }
});

// --------------------
// Get all reports (anyone)
// --------------------
router.get("/all", async (req, res) => {
  try {
    const reports = await Report.find().sort({ createdAt: -1 });
    res.json(reports);
  } catch (err) {
    res.status(500).json({ message: "Error fetching reports" });
  }
});

// --------------------
// Get my reports (user)
// --------------------
router.get("/mine", auth, async (req, res) => {
  try {
    const reports = await Report.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json(reports);
  } catch (err) {
    res.status(500).json({ message: "Error fetching your reports" });
  }
});

// --------------------
// Update report (admin only)
// --------------------
router.patch("/update/:id", auth, isAdmin, async (req, res) => {
  try {
    const { category, description, status, lat, lng } = req.body;
    const updatedData = { category, description, status };
    if (lat && lng) updatedData.location = { lat, lng };

    const report = await Report.findByIdAndUpdate(req.params.id, updatedData, { new: true });
    if (!report) return res.status(404).json({ message: "Report not found" });

    res.json(report);
  } catch (err) {
    res.status(500).json({ message: "Error updating report" });
  }
});

// --------------------
// Delete report (admin only)
// --------------------
router.delete("/delete/:id", auth, isAdmin, async (req, res) => {
  try {
    const report = await Report.findByIdAndDelete(req.params.id);
    if (!report) return res.status(404).json({ message: "Report not found" });

    res.json({ message: "Report deleted" });
  } catch (err) {
    res.status(500).json({ message: "Error deleting report" });
  }
});

export default router;
