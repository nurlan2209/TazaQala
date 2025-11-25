import express from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import User from "../models/User.js";
import { sendPasswordResetEmail } from "../utils/emailService.js";

const router = express.Router();

const buildAuthResponse = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role: user.role
});

const generateToken = () => crypto.randomBytes(32).toString("hex");
const generateNumericCode = () => Math.floor(100000 + Math.random() * 900000).toString();

// Register client
router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: "Барлық өрістерді толтырыңыз" });
    }

    // Құпия сөзді тексеру: кемі 6 символ, ішінде сан және арнайы символ болуы керек
    const hasMinLen = typeof password === "string" && password.length >= 6;
    const hasDigit = /\d/.test(password || "");
    const hasSpecial = /[^A-Za-z0-9]/.test(password || "");
    if (!hasMinLen || !hasDigit || !hasSpecial) {
      return res.status(400).json({
        message: "Құпия сөз 6+ символ, сан және арнайы символ қамтуы тиіс"
      });
    }

    const exist = await User.findOne({ email });
    if (exist) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const hash = await bcrypt.hash(password, 10);

    const user = new User({
      name,
      email,
      password: hash,
      role: "client",
      emailVerified: true,
      emailVerificationToken: undefined,
      emailVerificationExpires: undefined
    });
    await user.save();

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role,
        name: user.name
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Тіркелу сәтті",
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

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Wrong password" });

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role,
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

    const token = generateNumericCode();
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
