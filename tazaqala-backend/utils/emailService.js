import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const {
  SMTP_HOST,
  SMTP_PORT,
  SMTP_USER,
  SMTP_PASS,
  SMTP_SECURE,
  APP_URL
} = process.env;

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: Number(SMTP_PORT) || 587,
  secure: SMTP_SECURE === "true",
  connectionTimeout: 30000,
  greetingTimeout: 30000,
  socketTimeout: 30000,
  // Форсируем IPv4, чтобы обойти проблемы IPv6 на хостинге
  family: 4,
  tls: {
    rejectUnauthorized: false
  },
  auth: SMTP_USER
    ? {
        user: SMTP_USER,
        pass: SMTP_PASS
      }
    : undefined
});

const baseAppUrl = APP_URL || "http://localhost:5001";

const safeSend = async (options) => {
  if (process.env.DISABLE_EMAIL === "true") {
    console.warn("Email sending disabled via DISABLE_EMAIL");
    return;
  }
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) {
    console.warn(
      "SMTP credentials not configured, skip email",
      { host: SMTP_HOST, user: SMTP_USER }
    );
    return;
  }
  try {
    await transporter.sendMail({
      from: SMTP_USER,
      ...options
    });
  } catch (err) {
    console.error("Email send error:", err?.message || err);
    console.error("SMTP_HOST:", SMTP_HOST, "SMTP_PORT:", SMTP_PORT);
    throw err;
  }
};

export const sendVerificationEmail = async (to, token) => {
  const verifyUrl = `${baseAppUrl}/verify-email?token=${token}`;
  await safeSend({
    to,
    subject: "TazaQala | Email растау",
    html: `
      <p>Сәлеметсіз бе!</p>
      <p>TazaQala сервисінде тіркелуді аяқтау үшін email-ді растаңыз.</p>
      <p><a href="${verifyUrl}" target="_blank">Растау сілтемесі</a></p>
      <p>Егер бұл сұранысты сіз жасамаған болсаңыз, осы хатты елемеуге болады.</p>
    `
  });
};

export const sendPasswordResetEmail = async (to, token) => {
  await safeSend({
    to,
    subject: "TazaQala | Құпия сөзді жаңарту коды",
    html: `
      <p>Құпия сөзді жаңарту үшін төмендегі кодты қолданыңыз.</p>
      <p><strong>Код:</strong> <span style="font-size:18px;">${token}</span></p>
      <p>Код 1 сағат ішінде жарамды.</p>
    `
  });
};

export const sendReportStatusEmail = async ({ to, report, status }) => {
  await safeSend({
    to,
    subject: "TazaQala | Шағым статусы жаңартылды",
    html: `
      <p>Сіздің "${report.category}" шағымыңыздың статусы өзгерді.</p>
      <p>Жаңа статус: <strong>${status}</strong></p>
      <p>Сипаттама: ${report.description}</p>
    `
  });
};
