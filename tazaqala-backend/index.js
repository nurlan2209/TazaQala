import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/db.js";

import authRoutes from "./routes/auth.js";
import reportRoutes from "./routes/reports.js";

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

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
