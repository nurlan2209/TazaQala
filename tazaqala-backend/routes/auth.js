import express from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import User from "../models/User.js";
import DISTRICTS from "../config/districts.js";
import {
  sendVerificationEmail,
  sendPasswordResetEmail
} from "../utils/emailService.js";

const router = express.Router();

const buildAuthResponse = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role: user.role,
  district: user.district
});

const generateToken = () => crypto.randomBytes(32).toString("hex");

// Register client
router.post("/register", async (req, res) => {
  try {
    const { name, email, password, district } = req.body;

    if (!name || !email || !password || !district) {
      return res
        .status(400)
        .json({ message: "Барлық өрістерді толтырыңыз" });
    }

    if (!DISTRICTS.includes(district)) {
      return res.status(400).json({ message: "Аудан дұрыс емес" });
    }

    const exist = await User.findOne({ email });
    if (exist) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const hash = await bcrypt.hash(password, 10);
    const verificationToken = generateToken();
    const expires = Date.now() + 1000 * 60 * 60 * 24; // 24h

    const user = new User({
      name,
      email,
      password: hash,
      role: "client",
      district,
      emailVerificationToken: verificationToken,
      emailVerificationExpires: expires
    });
    await user.save();

    await sendVerificationEmail(email, verificationToken);

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role,
        district: user.district,
        name: user.name
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Тіркелу сәтті. Email-ге растау сілтемесі жіберілді.",
      token,
      user: buildAuthResponse(user)
    });
  } catch (err) {
    console.error("Register error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email және пароль қажет" });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "User not found" });
    if (!user.isActive) {
      return res.status(403).json({ message: "Аккаунт бұғатталған" });
    }
    if (!user.emailVerified) {
      return res
        .status(403)
        .json({ message: "Email расталмаған. Поштаңызды тексеріңіз." });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Wrong password" });

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role,
        district: user.district,
        name: user.name
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({ token, user: buildAuthResponse(user) });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Verify email
router.get("/verify-email", async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) {
      return res.status(400).json({ message: "Token табылмады" });
    }

    const user = await User.findOne({
      emailVerificationToken: token,
      emailVerificationExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ message: "Token жарамсыз немесе мерзімі өтті" });
    }

    user.emailVerified = true;
    user.emailVerificationToken = undefined;
    user.emailVerificationExpires = undefined;
    await user.save();

    res.json({ message: "Email расталды" });
  } catch (err) {
    console.error("Verify email error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Resend verification
router.post("/resend-verification", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: "Email енгізіңіз" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }
    if (user.emailVerified) {
      return res.status(400).json({ message: "Email бұрын расталған" });
    }

    const token = generateToken();
    user.emailVerificationToken = token;
    user.emailVerificationExpires = Date.now() + 1000 * 60 * 60 * 24;
    await user.save();

    await sendVerificationEmail(email, token);
    res.json({ message: "Растау сілтемесі қайта жіберілді" });
  } catch (err) {
    console.error("Resend verification error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Forgot password
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: "Email енгізіңіз" });
    }
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(200)
        .json({ message: "Егер email тіркелген болса, сілтеме жіберілді" });
    }

    const token = generateToken();
    user.resetPasswordToken = token;
    user.resetPasswordExpires = Date.now() + 1000 * 60 * 60; // 1h
    await user.save();

    await sendPasswordResetEmail(email, token);
    res.json({ message: "Құпия сөзді жаңарту сілтемесі жіберілді" });
  } catch (err) {
    console.error("Forgot password error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Reset password
router.post("/reset-password", async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) {
      return res
        .status(400)
        .json({ message: "Token және жаңа құпия сөз қажет" });
    }

    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ message: "Token жарамсыз немесе мерзімі өтті" });
    }

    user.password = await bcrypt.hash(password, 10);
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.json({ message: "Құпия сөз жаңартылды" });
  } catch (err) {
    console.error("Reset password error:", err);
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

export default router;
