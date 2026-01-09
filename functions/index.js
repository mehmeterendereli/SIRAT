const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

// Initialize Gemini AI with environment variable
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

// Firestore reference for logging
const db = admin.firestore();

// Yasaklı kelimeler listesi (Siyasi/Tartışmalı konular)
const BANNED_KEYWORDS = [
    "siyaset", "parti", "seçim", "oy", "politika",
    "terör", "şiddet", "savaş", "cihat", "öldürme",
    "mezhep çatışması", "tekfir"
];

/**
 * SIRAT - İslam-AI Asistan
 * Gelişmiş System Prompt Mühendisliği ile Gemini Pro Entegrasyonu
 */

// ============ SYSTEM PROMPTS ============

const SYSTEM_PROMPTS = {
    // Mod 1: Fetva/Bilgi Modu
    FETVA: (mezhep) => `
Sen "SIRAT" uygulamasının resmi İslam Alimi asistanısın.
Kullanıcının mezhebi: ${mezhep}.

MUTLAK KURALLAR:
1. SADECE ehli sünnet vel cemaat itikadına ve ${mezhep} fıkhına göre cevap ver.
2. Her cevabı şu kaynaklarla MUTLAKA destekle:
   - Kuran ayetleri: "Sure İsmi, Ayet No" formatında
   - Hadisler: "Kütüb-i Sitte kaynaklarından (Buhari/Müslim/Tirmizi/Ebu Davud/Nesai/İbn Mace) kitap ve hadis numarası ile"
3. Kendi yorumunu ASLA katma. Sadece muteber alimlerin görüşlerini naklet.
4. Siyasi, tartışmalı veya mezhep ayrılığı konularına GİRME.
5. Her cevabı şu formatta bitir:
   "📚 Kaynak: [Kaynak Adı]
    🤲 Allah en doğrusunu bilir."

CEVAP FORMATI:
- Kısa ve öz ol (maksimum 300 kelime)
- Madde işaretleri kullan
- Arapça terimleri parantez içinde açıkla
`,

    // Mod 2: Psikolojik/Manevi Destek Modu
    TESELLI: (mezhep) => `
Sen "SIRAT" uygulamasının manevi destek asistanısın.
Kullanıcının mezhebi: ${mezhep}.

GÖREVIN:
1. Kullanıcıya İslami perspektiften teselli ve moral ver.
2. Duruma uygun Kuran ayeti veya hadis öner.
3. Yapılabilecek dua veya zikir tavsiye et.
4. Şefkatli, anlayışlı ve destekleyici bir üslup kullan.

CEVAP İÇERMELİ:
- Teselli edici bir mesaj
- İlgili bir ayet veya hadis (kaynaklı)
- Önerilen dua metni (Arapça + Okunuşu + Meali)
- "Senin için dua ediyorum" gibi destekleyici kapanış

ASLA:
- Tıbbi veya psikolojik tedavi önerme
- "Bir uzmana danış" deme (bunun yerine "Allah şifanı versin" de)
- Olumsuz veya yargılayıcı olma
`,

    // Mod 3: Günlük İbadet Yardımcısı
    IBADET: (mezhep) => `
Sen "SIRAT" uygulamasının ibadet yardımcısısın.
Kullanıcının mezhebi: ${mezhep}.

UZMANLIK ALANLARIN:
- Namaz (Kılınışı, Şartları, Vacipleri)
- Abdest ve Gusül
- Oruç
- Zekat ve Fitre
- Hac ve Umre

${mezhep} fıkhına göre PRATİK ve ANLAŞILIR cevaplar ver.
Adım adım talimatlar kullan.
`
};

// ============ MAIN FUNCTION ============

exports.askIslamicAI = functions.https.onCall(async (data, context) => {
    // Authentication check
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "Bu işlem için giriş yapmalısınız."
        );
    }

    const userId = context.auth.uid;
    const userQuestion = data.question?.trim();
    const userMezhep = data.mezhep || "Hanefi";
    const mode = data.mode || "FETVA"; // FETVA, TESELLI, IBADET

    // Validation
    if (!userQuestion || userQuestion.length < 3) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Soru en az 3 karakter olmalıdır."
        );
    }

    if (userQuestion.length > 500) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Soru 500 karakterden uzun olamaz."
        );
    }

    // Banned keyword check
    const lowerQuestion = userQuestion.toLowerCase();
    for (const banned of BANNED_KEYWORDS) {
        if (lowerQuestion.includes(banned)) {
            return {
                answer: "Bu konuda cevap veremiyorum. Lütfen dini konularla ilgili bir soru sorun.",
                filtered: true,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            };
        }
    }

    // Get appropriate system prompt
    const systemPrompt = SYSTEM_PROMPTS[mode]?.(userMezhep) || SYSTEM_PROMPTS.FETVA(userMezhep);

    try {
        const prompt = `${systemPrompt}\n\n📝 KULLANICI SORUSU:\n${userQuestion}`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const answerText = response.text();

        // Log query for analytics (anonimize)
        await db.collection("ai_queries").add({
            userId: userId,
            mode: mode,
            mezhep: userMezhep,
            questionLength: userQuestion.length,
            answerLength: answerText.length,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            // Sorunun kendisini saklamıyoruz - privacy
        });

        return {
            answer: answerText,
            mode: mode,
            mezhep: userMezhep,
            filtered: false,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        };

    } catch (error) {
        console.error("Gemini AI Error:", error);

        // Log error
        await db.collection("ai_errors").add({
            userId: userId,
            errorCode: error.code || "unknown",
            errorMessage: error.message,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        throw new functions.https.HttpsError(
            "internal",
            "Yapay zeka şu an meşgul. Lütfen biraz sonra tekrar deneyin."
        );
    }
});

/**
 * getDailyInsight
 * Her gün otomatik üretilen manevi içerik
 */
exports.getDailyInsight = functions.https.onCall(async (data, context) => {
    const type = data.type || "hadis"; // hadis, ayet, dua
    const lang = data.lang || "tr";

    const prompts = {
        hadis: "Bugün için kısa, motivasyonel bir hadis-i şerif öner. Kaynağını belirt.",
        ayet: "Bugün için kısa, ilham verici bir Kuran ayeti öner. Sure ve ayet numarasını belirt.",
        dua: "Günlük okunan kısa ve etkili bir dua öner. Arapça, okunuşu ve mealini ver."
    };

    try {
        const result = await model.generateContent(prompts[type] || prompts.hadis);
        const response = await result.response;

        return {
            content: response.text(),
            type: type,
            lang: lang,
            date: new Date().toISOString().split('T')[0]
        };
    } catch (error) {
        console.error("Daily Insight Error:", error);
        throw new functions.https.HttpsError("internal", "İçerik üretilemedi.");
    }
});
