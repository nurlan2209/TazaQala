import "./polyfills.js";
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/db.js";

import authRoutes from "./routes/auth.js";
import reportRoutes from "./routes/reports.js";
import userRoutes from "./routes/users.js";
import newsRoutes from "./routes/news.js";
import astanaNewsRoutes from "./routes/astanaNews.js";
import proxyRoutes from "./routes/proxy.js";

dotenv.config();
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Подключаем базу
connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/users", userRoutes);
app.use("/api/news", newsRoutes);
app.use("/api/astana-news", astanaNewsRoutes);
app.use("/api/proxy", proxyRoutes);

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
