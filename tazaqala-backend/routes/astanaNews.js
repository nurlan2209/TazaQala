import express from "express";
import axios from "axios";
import parseAstanaNews from "../utils/astanaNewsParser.js";

const router = express.Router();
const BASE_URL =
  "https://tengrinews.kz/tag/%D0%B0%D1%81%D1%82%D0%B0%D0%BD%D0%B0/";

const buildUrl = (page) => {
  if (page <= 1) return BASE_URL;
  return `${BASE_URL}page/${page}/`;
};

router.get("/", async (req, res) => {
  try {
    const page = Number(req.query.page) || 1;
    const targetUrl = buildUrl(page);

    const response = await axios.get(targetUrl, {
      headers: { "User-Agent": "Mozilla/5.0" },
      timeout: 10000
    });

    const cards = parseAstanaNews(response.data);
    res.json(cards);
  } catch (err) {
    console.error("Astana news fetch error:", err.message || err);
    res
      .status(500)
      .json({ error: "failed to fetch or parse Tengrinews Astana page" });
  }
});

export default router;
