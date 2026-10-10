# UNIVERSTREE — Production-Grade College Registration Workflow

---

## 1. Overview
The **College Registration Workflow** enables official institutional representatives (Principals, Deans, Registrars, IT Officers) to register their institution on **Universtree** (`/college/register`).

The architecture strictly separates **Verification** from **Authorization**:
- **Email & Phone Verification**: Confirms control of an official email and office phone.
- **Authorization**: Confirms legitimate representative status via official documents and platform Super Admin review.

---

## 2. Multi-Step Registration Architecture

```
Step 1: Representative Details (Name, Designation, Official Email, Office Phone)
   ↓
Step 2: Official Email Verification (Personal emails rejected BEFORE sending OTP)
   ↓
Step 3: Office Phone SMS Verification (Firebase Phone Auth OTP)
   ↓
Step 4: Institution Information (Name, Type, Official Website, Email Domain)
   ↓
Step 5: Google Maps Search & Location Geocoding Extraction
   ↓
Step 6: Firebase Storage Authorization Documents Upload (PDF / Images, Max 10MB)
   ↓
Step 7: Final Review & Submission -> Firestore PENDING State -> Application ID (UT-2026-XXXXXXXX)
```

---

## 3. Security Boundary Rules
1. **Personal Email Rejection**: Addresses ending in `@gmail.com`, `@yahoo.com`, `@outlook.com`, `@hotmail.com`, `@icloud.com`, etc. are rejected immediately. Verification codes are NEVER sent to personal email addresses.
2. **Verification Gatekeeper**: Progression to final submission is locked until both `emailVerified == true` and `phoneVerified == true`.
3. **Firestore Security Rules**: The `collegeApplications/{applicationId}` Firestore collection strictly defaults to `status: "PENDING"`. Applicants cannot write `status: "APPROVED"`.
4. **Storage Rules**: Authorization files are stored in `institution-applications/{uid}/{applicationId}/authorization/` with path access restricted to the applicant and Super Admins.

---

## 4. Super Admin Review Interface
Super Administrators access pending applications via `/platform-admin/dashboard` to:
- Review Representative name, designation, verified email, and phone.
- Inspect Google Maps geocoded location.
- Download and review uploaded authorization documents.
- Execute **Approve & Whitelist** or **Reject** (with mandatory rejection reason) writing to `collegeApplicationAuditLogs`.
