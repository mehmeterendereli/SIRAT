const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

// Initialize Gemini AI
// Note: API Key should be stored in Secret Manager or environment variables
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

/**
 * askIslamicAI
 * HTTPS Callable function to interact with Gemini Pro with custom system prompt.
 */
exports.askIslamicAI = functions.https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated."
        );
    }

    const userQuestion = data.question;
    const userMezhep = data.mezhep || "Hanefi";

    if (!userQuestion) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Question cannot be empty."
        );
    }

    const systemPrompt = `
    Sen "SIRAT" uygulamasının resmi İslam Alimi asistanısın. 
    Kullanıcının mezhebi: ${userMezhep}.
    
    KURALLAR:
    1. Sadece ehli sünnet vel cemaat itikadı ve ${userMezhep} fıkhına göre cevap ver.
    2. Cevaplarını Kuran ayetleri (Sure ismi ve Ayet No) ve Kütüb-i Sitte hadisleri (Kaynak kitap ve No) ile destekle.
    3. Asla kişisel yorum katma, sadece muteber kaynaklardan nakil yap.
    4. Siyasi veya tartışmalı konulara girme.
    5. Cevap sonunda mutlaka "Allah en doğrusunu bilir." ve "Daha fazlası için şu kaynağa bakabilirsin: [Kaynak]" de.
  `;

    try {
        const prompt = `${systemPrompt}\n\nKullanıcı Sorusu: ${userQuestion}`;
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        return {
            answer: text,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        };
    } catch (error) {
        console.error("Gemini AI Error:", error);
        throw new functions.https.HttpsError("internal", "AI model failed to respond.");
    }
});
