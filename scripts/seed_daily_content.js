// Firestore Daily Content Seed Script
// Run with: node scripts/seed_daily_content.js

const admin = require('firebase-admin');

// Initialize with default credentials
admin.initializeApp();

const db = admin.firestore();

const dailyContent = [
    {
        id: 'ayet_fatiha',
        type: 'ayet',
        title: 'Günün Ayeti',
        content: 'Rahman ve Rahim olan Allah\'ın adıyla. Hamd, âlemlerin Rabbi Allah\'a mahsustur.',
        source: 'Fatiha Suresi, 1-2',
        icon_code: 'book',
        priority: 1,
        active: true
    },
    {
        id: 'hadis_niyet',
        type: 'hadis',
        title: 'Günün Hadisi',
        content: 'Ameller niyetlere göredir. Herkesin niyeti ne ise eline geçecek olan odur.',
        source: 'Buhari, Müslim',
        icon_code: 'star',
        priority: 2,
        active: true
    },
    {
        id: 'dua_sabah',
        type: 'dua',
        title: 'Sabah Duası',
        content: 'Allahümme bike asbahna ve bike emseyna ve bike nahya ve bike nemut ve ileykennuşur.',
        source: 'Sabah Zikri',
        icon_code: 'favorite',
        priority: 3,
        active: true
    },
    {
        id: 'bilgi_namaz',
        type: 'bilgi',
        title: 'Faydalı Bilgi',
        content: 'Beş vakit namaz, günahların kefaretidir. Tıpkı kapının önünden akan ve her gün beş defa yıkandığınız bir nehir gibidir.',
        source: 'Buhari, Müslim',
        icon_code: 'lightbulb',
        priority: 4,
        active: true
    }
];

async function seedDailyContent() {
    console.log('Seeding daily_content collection...');

    const batch = db.batch();

    for (const item of dailyContent) {
        const docRef = db.collection('daily_content').doc(item.id);
        batch.set(docRef, {
            ...item,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log(`  Added: ${item.title}`);
    }

    await batch.commit();
    console.log('Daily content seeded successfully!');
}

seedDailyContent()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error('Error:', err);
        process.exit(1);
    });
