import express from "express";
import News from "../models/News.js";
import DISTRICTS from "../config/districts.js";
import { auth, authorizeRoles } from "../middleware/auth.js";

const router = express.Router();

// Public list
router.get("/", async (req, res) => {
  try {
    const { district } = req.query;
    const filter = { isPublished: true };

    if (district && DISTRICTS.includes(district)) {
      filter.district = district;
    }

    const news = await News.find(filter).sort({ publishedAt: -1 });
    res.json(news);
  } catch (err) {
    console.error("Fetch news error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Create news (admin/director)
router.post(
  "/",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { title, description, district, imageUrl, isPublished } = req.body;
      if (!title || !description || !district) {
        return res
          .status(400)
          .json({ message: "Барлық өрістерді толтырыңыз" });
      }

      if (!DISTRICTS.includes(district)) {
        return res.status(400).json({ message: "Аудан дұрыс емес" });
      }

      const newsItem = new News({
        title,
        description,
        district,
        imageUrl,
        isPublished: isPublished !== undefined ? isPublished : true,
        createdBy: req.user.id,
        publishedAt: new Date()
      });

      await newsItem.save();
      res.status(201).json(newsItem);
    } catch (err) {
      console.error("Create news error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// Update news
router.patch(
  "/:id",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { title, description, district, imageUrl, isPublished } = req.body;
      const newsItem = await News.findById(req.params.id);
      if (!newsItem) {
        return res.status(404).json({ message: "Жаңалық табылмады" });
      }

      if (title) newsItem.title = title;
      if (description) newsItem.description = description;
      if (typeof isPublished === "boolean") newsItem.isPublished = isPublished;
      if (imageUrl !== undefined) newsItem.imageUrl = imageUrl;
      if (district) {
        if (!DISTRICTS.includes(district)) {
          return res.status(400).json({ message: "Аудан дұрыс емес" });
        }
        newsItem.district = district;
      }

      await newsItem.save();
      res.json(newsItem);
    } catch (err) {
      console.error("Update news error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// Delete
router.delete(
  "/:id",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const deleted = await News.findByIdAndDelete(req.params.id);
      if (!deleted) {
        return res.status(404).json({ message: "Жаңалық табылмады" });
      }
      res.json({ message: "Жаңалық жойылды" });
    } catch (err) {
      console.error("Delete news error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

export default router;
