# UNIVERSTREE — Firebase Production Setup Guide

---

## 1. Firebase Project Overview
- **Project ID**: `universtree-3d91e`
- **Package Name (Android)**: `com.universtree.app`

---

## 2. Configured Firebase Services
1. **Firebase Authentication**: Email/Password, Email Verification Links, Phone Auth SMS OTP.
2. **Cloud Firestore**: Multi-tenant database storing `users`, `colleges`, `collegeApplications`, `faculty_verification_requests`, and `collegeApplicationAuditLogs`.
3. **Firebase Storage**: File bucket storing authorization proof documents in `institution-applications/{uid}/{applicationId}/`.
4. **Security Rules**: Deployed via `firestore.rules` and `storage.rules`.

---

## 3. Deployment Commands

```bash
# Login to Firebase CLI
firebase login

# Deploy Firestore Security Rules
firebase deploy --only firestore:rules

# Deploy Storage Security Rules
firebase deploy --only storage

# Run Flutter Static Analysis
flutter analyze

# Run Automated Test Suite
flutter test
```
