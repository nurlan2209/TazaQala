import axios from "axios";

// Simple in-memory cache to avoid hitting rate limits.
const cache = new Map();

export const detectDistrict = async (lat, lng) => {
  const key = `${lat.toFixed(5)},${lng.toFixed(5)}`;
  if (cache.has(key)) return cache.get(key);

  try {
    const { data } = await axios.get(
      "https://nominatim.openstreetmap.org/reverse",
      {
        params: {
          format: "jsonv2",
          lat,
          lon: lng,
          "accept-language": "ru"
        },
        headers: {
          "User-Agent": "tazaqala-demo"
        },
        timeout: 5000
      }
    );

    const district =
      data?.address?.city_district ||
      data?.address?.suburb ||
      data?.address?.neighbourhood;

    if (district) {
      cache.set(key, district);
      return district;
    }
    return null;
  } catch (err) {
    console.error("Reverse geocode error:", err.message || err);
    return null;
  }
};

export default detectDistrict;
