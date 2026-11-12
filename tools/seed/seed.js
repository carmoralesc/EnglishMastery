// Seed de Firestore para English Master Academy.
// Uso: npm run seed  (desde tools/seed/)
// Requiere serviceAccountKey.json en esta carpeta.
// Idempotente: usa .set() (sobrescribe) — correr 2 veces no duplica.

const admin = require('firebase-admin');
const content = require('./content/level1.json');

admin.initializeApp({
    credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

async function seedLevel(level) {
    const { id: levelId, sessions, ...levelFields } = level;
    const totalTasks = sessions.reduce((sum, s) => sum + s.tasks.length, 0);

    await db.collection('levels').doc(levelId).set({
        ...levelFields,
        totalTasks,
    });
    console.log(`✓ levels/${levelId} (${totalTasks} tasks)`);

    for (const session of sessions) {
        const { id: sessionId, tasks, ...sessionFields } = session;
        const taskIds = tasks.map((t) => t.id);

        await db
            .collection('levels').doc(levelId)
            .collection('sessions').doc(sessionId)
            .set({ ...sessionFields, levelId, taskIds });
        console.log(`  ✓ levels/${levelId}/sessions/${sessionId}`);

        for (const task of tasks) {
            const { id: taskId, ...taskFields } = task;
            await db.collection('tasks').doc(taskId).set({
                ...taskFields,
                sessionId,
            });
            console.log(`    ✓ tasks/${taskId}`);
        }
    }
}

async function main() {
    for (const level of content.levels) {
        await seedLevel(level);
    }
    console.log('\n✅ Seed completo');
}

main().catch((err) => {
    console.error('❌ Error en seed:', err);
    process.exit(1);
});