import mongoose from "mongoose";
import DISTRICTS from "../config/districts.js";

const newsSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String, required: true },
    district: { type: String, enum: DISTRICTS, required: true },
    imageUrl: { type: String },
    isPublished: { type: Boolean, default: true },
    publishedAt: { type: Date, default: Date.now },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  },
  { timestamps: true }
);

export default mongoose.model("News", newsSchema);
