import express from "express";
import bcrypt from "bcrypt";
import User from "../models/User.js";
import { auth, authorizeRoles } from "../middleware/auth.js";

const router = express.Router();

const sanitizeUser = (user) => {
  const obj = user.toObject();
  delete obj.password;
  delete obj.resetPasswordToken;
  delete obj.resetPasswordExpires;
  delete obj.emailVerificationToken;
  delete obj.emailVerificationExpires;
  return obj;
};

// List staff users
router.get(
  "/admins",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const role = typeof req.query.role === "string" ? req.query.role : "staff";
      const allowedRoles = ["admin", "staff"];
      if (!allowedRoles.includes(role)) {
        return res.status(400).json({ message: "Рөл дұрыс емес" });
      }
      const admins = await User.find({ role }).select("-password").sort({ name: 1 });
      res.json(admins);
    } catch (err) {
      console.error("Fetch admins error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// Create new staff user
router.post(
  "/admins",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { name, email, password, role } = req.body;
      // Директор всегда создаёт админов. Админ создаёт только staff.
      let targetRole = "staff";
      if (req.user.role === "director") {
        targetRole = "admin";
      } else if (role === "staff") {
        targetRole = "staff";
      }

      if (!name || !email || !password) {
        return res
          .status(400)
          .json({ message: "Барлық өрістерді толтырыңыз" });
      }

      if (targetRole === "admin" && req.user.role !== "director") {
        return res.status(403).json({ message: "Тек директор үшін" });
      }

      const exist = await User.findOne({ email });
      if (exist) {
        return res.status(400).json({ message: "Email already exists" });
      }

      const hash = await bcrypt.hash(password, 10);
      const admin = new User({
        name,
        email,
        password: hash,
        role: targetRole,
        createdBy: req.user.id
      });

      await admin.save();
      const sanitized = admin.toObject();
      delete sanitized.password;
      res.status(201).json({ message: "Админ қосылды", admin: sanitized });
    } catch (err) {
      console.error("Create admin error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// Update staff info / reset password
router.patch(
  "/admins/:id",
  auth,
  authorizeRoles("admin", "director"),
  async (req, res) => {
    try {
      const { name, email, password, isActive, role } = req.body;
      const admin = await User.findOne({
        _id: req.params.id,
        role: { $in: ["staff", "admin"] }
      });

      if (!admin) {
        return res.status(404).json({ message: "Админ табылмады" });
      }

      if (email && email !== admin.email) {
        const emailTaken = await User.findOne({ email });
        if (emailTaken) {
          return res.status(400).json({ message: "Email already exists" });
        }
        admin.email = email;
      }

      if (name) admin.name = name;
      if (typeof isActive === "boolean") admin.isActive = isActive;
      if (role && role === "admin") {
        if (req.user.role !== "director") {
          return res.status(403).json({ message: "Тек директор үшін" });
        }
        admin.role = "admin";
      }

      if (password) {
        admin.password = await bcrypt.hash(password, 10);
      }

      admin.createdBy = req.user.id;
      await admin.save();

      const sanitized = admin.toObject();
      delete sanitized.password;
      res.json({ message: "Жаңартылды", admin: sanitized });
    } catch (err) {
      console.error("Update admin error:", err);
      res.status(500).json({ message: "Сервер қатесі" });
    }
  }
);

// Update own profile
router.patch("/me", auth, async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (email && email !== user.email) {
      const exists = await User.findOne({ email });
      if (exists) {
        return res.status(400).json({ message: "Email already exists" });
      }
      user.email = email;
      user.emailVerified = false;
    }

    if (name) user.name = name;
    if (password) {
      user.password = await bcrypt.hash(password, 10);
    }

    await user.save();
    res.json({ message: "Жаңартылды", user: sanitizeUser(user) });
  } catch (err) {
    console.error("Update self error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

export default router;
