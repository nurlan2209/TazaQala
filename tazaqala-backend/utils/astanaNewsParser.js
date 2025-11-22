import * as cheerio from "cheerio";

const BASE_URL = "https://tengrinews.kz";

export const parseAstanaNews = (html) => {
  const $ = cheerio.load(html);
  const cards = [];

  $(".content_main_item").each((_, element) => {
    const card = $(element);

    const titleEl = card.find(".content_main_item_title a").first();
    let title = titleEl.text().trim();
    let url = titleEl.attr("href");

    if (!url) {
      const fallbackLink = card.find("a").first();
      url = fallbackLink.attr("href");
      if (!title) {
        title = fallbackLink.text().trim();
      }
    }

    if (!title && !url) {
      return;
    }

    if (url && url.startsWith("/")) {
      url = `${BASE_URL}${url}`;
    }

    const description = card.find(".content_main_item_announce").text().trim();

    const date = card
      .find(".content_main_item_meta time")
      .first()
      .text()
      .trim();

    const image = card.find(".content_main_item_img").attr("src") || null;

    cards.push({
      title: title || null,
      url: url || null,
      description: description || null,
      date: date || null,
      image,
      source: "tengrinews",
      tag: "Астана",
    });
  });

  return cards.filter((item) => item.title && item.url);
};

export default parseAstanaNews;
