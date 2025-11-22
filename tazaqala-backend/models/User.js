import mongoose from "mongoose";
import DISTRICTS from "../config/districts.js";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: {
      type: String,
      enum: ["director", "admin", "client"],
      default: "client"
    },
    district: {
      type: String,
      enum: DISTRICTS,
      required: function requiredDistrict() {
        return this.role !== "director";
      }
    },
    isActive: { type: Boolean, default: true },
    emailVerified: { type: Boolean, default: false },
    emailVerificationToken: String,
    emailVerificationExpires: Date,
    resetPasswordToken: String,
    resetPasswordExpires: Date,
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
