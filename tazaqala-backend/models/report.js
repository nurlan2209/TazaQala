import mongoose from "mongoose";

const reportSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    category: { type: String, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String, required: true },
    location: {
      lat: Number,
      lng: Number
    },
    status: { type: String, default: "new" } // new, reviewing, in_progress, done
  },
  { timestamps: true }
);

export default mongoose.model("Report", reportSchema);
