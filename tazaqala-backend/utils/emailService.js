import nodemailer from "nodemailer";

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
  auth: SMTP_USER
    ? {
        user: SMTP_USER,
        pass: SMTP_PASS
      }
    : undefined
});

const baseAppUrl = APP_URL || "http://localhost:5001";

const safeSend = async (options) => {
  if (!SMTP_HOST) {
    console.warn("SMTP credentials not configured, skip email");
    return;
  }
  await transporter.sendMail({
    from: SMTP_USER,
    ...options
  });
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
  const resetUrl = `${baseAppUrl}/reset-password?token=${token}`;
  await safeSend({
    to,
    subject: "TazaQala | Құпия сөзді жаңарту",
    html: `
      <p>Құпия сөзді жаңарту үшін төмендегі сілтемеге өтіңіз:</p>
      <p><a href="${resetUrl}" target="_blank">Құпия сөзді жаңарту</a></p>
      <p>Сілтеме 1 сағат ішінде жарамды.</p>
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
