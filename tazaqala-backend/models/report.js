import mongoose from "mongoose";
import DISTRICTS from "../config/districts.js";

const STATUS_VALUES = ["new", "reviewing", "in_progress", "done"];

const reportSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    district: { type: String, enum: DISTRICTS, required: true },
    category: { type: String, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String, required: true },
    location: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true }
    },
    status: { type: String, enum: STATUS_VALUES, default: "new" }
  },
  { timestamps: true }
);

export default mongoose.model("Report", reportSchema);
