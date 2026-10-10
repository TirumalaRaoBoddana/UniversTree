/**
 * Universtree Platform Administrator One-Time Provisioning Script
 *
 * Usage:
 *   export ADMIN_EMAIL="universtreeapp@gmail.com"
 *   export ADMIN_PASSWORD="universtree_admin@1234#"
 *   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
 *   node provision_platform_admin.js
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: 'universtree-3d91e',
    });
  } catch (e) {
    admin.initializeApp({
      projectId: 'universtree-3d91e',
    });
  }
}

const auth = admin.auth();
const db = admin.firestore();

async function provisionPlatformAdmin() {
  const adminEmail = (process.env.ADMIN_EMAIL || 'universtreeapp@gmail.com').trim().toLowerCase();
  const adminPassword = process.env.ADMIN_PASSWORD || 'universtree_admin@1234#';
  const displayName = 'Universtree Platform Administrator';

  console.log(`[Provisioning] Starting Platform Administrator setup for: ${adminEmail}`);

  let userRecord;

  // 1. Check if Firebase Auth user already exists
  try {
    userRecord = await auth.getUserByEmail(adminEmail);
    console.log(`[Provisioning] Found existing Firebase Auth account. UID: ${userRecord.uid}`);

    // Ensure account is email verified
    if (!userRecord.emailVerified) {
      userRecord = await auth.updateUser(userRecord.uid, {
        emailVerified: true,
      });
      console.log(`[Provisioning] Updated account emailVerified status to true.`);
    }
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.log(`[Provisioning] Account not found. Creating new Firebase Auth user...`);
      userRecord = await auth.createUser({
        email: adminEmail,
        password: adminPassword,
        emailVerified: true,
        displayName: displayName,
      });
      console.log(`[Provisioning] Successfully created Firebase Auth user. UID: ${userRecord.uid}`);
    } else {
      console.error(`[Provisioning Error] Failed to query Firebase Auth:`, error.message);
      process.exit(1);
    }
  }

  const uid = userRecord.uid;

  // 2. Assign Custom Claims: { platformAdmin: true, role: 'platform_admin' }
  try {
    await auth.setCustomUserClaims(uid, {
      platformAdmin: true,
      role: 'platform_admin',
    });
    console.log(`[Provisioning] Assigned custom claims { platformAdmin: true, role: 'platform_admin' } to UID: ${uid}`);
  } catch (error) {
    console.error(`[Provisioning Error] Failed to set custom user claims:`, error.message);
  }

  // 3. Create/Update General User Profile at /users/{uid}
  try {
    const userRef = db.collection('users').doc(uid);
    await userRef.set(
      {
        uid: uid,
        email: adminEmail,
        displayName: displayName,
        role: 'platform_admin',
        accountType: 'platform_administrator',
        isActive: true,
        emailVerified: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    console.log(`[Provisioning] Successfully synchronized Firestore profile at /users/${uid}`);
  } catch (error) {
    console.error(`[Provisioning Error] Failed to write Firestore user profile:`, error.message);
  }

  // 4. Create/Update Dedicated Administrator Profile at /platform_administrators/{uid}
  try {
    const adminRef = db.collection('platform_administrators').doc(uid);
    await adminRef.set(
      {
        uid: uid,
        email: adminEmail,
        displayName: displayName,
        role: 'platform_admin',
        adminLevel: 'super_admin',
        isActive: true,
        permissions: {
          viewRegistrations: true,
          reviewRegistrations: true,
          approveRegistrations: true,
          rejectRegistrations: true,
          viewDocuments: true,
          viewAuditLogs: true,
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    console.log(`[Provisioning] Successfully synchronized Dedicated Admin profile at /platform_administrators/${uid}`);
  } catch (error) {
    console.error(`[Provisioning Error] Failed to write Dedicated Admin profile:`, error.message);
  }

  console.log(`\n[Provisioning Complete] Platform Administrator account setup is complete and idempotent.`);
  console.log(`Firebase UID: ${uid}`);
  console.log(`Email: ${adminEmail}`);
  console.log(`Role: platform_admin`);
}

provisionPlatformAdmin().catch((err) => {
  console.error('[Provisioning Exception]', err);
  process.exit(1);
});
