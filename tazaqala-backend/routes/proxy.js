import express from "express";
import axios from "axios";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const { url } = req.query;
    if (!url || typeof url !== "string") {
      return res.status(400).json({ message: "url param required" });
    }

    const response = await axios.get(url, {
      responseType: "arraybuffer",
      timeout: 10000,
      headers: {
        "User-Agent": "Mozilla/5.0",
      },
    });

    const contentType = response.headers["content-type"] || "application/octet-stream";
    res.set("Content-Type", contentType);
    res.set("Access-Control-Allow-Origin", "*");
    res.send(response.data);
  } catch (err) {
    console.error("Image proxy error:", err.message || err);
    res.status(500).json({ message: "Proxy error" });
  }
});

export default router;
