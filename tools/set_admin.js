
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const serviceAccount = require('./serviceAccount.json');

const app = initializeApp({
    credential: cert(serviceAccount),
});

async function setAdmin(email) {
    try {
        const auth = getAuth(app);
        const user = await auth.getUserByEmail(email);

        await auth.setCustomUserClaims(user.uid, {
            admin: true,
        });

        console.log(`Success! ${email} is now an admin.`);
        console.log(`UID: ${user.uid}`);
    } catch (error) {
        console.error('Error setting admin:', error.message);
        process.exitCode = 1;
    } finally {
        await app.delete();
    }
}

const email = process.argv[2];

if (!email) {
    console.error('Usage: node set_admin.js user@example.com');
    process.exitCode = 1;
} else {
    setAdmin(email);
}