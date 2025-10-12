# Privacy Policy for MealAdvisor

**Last Updated**: October 11, 2025  
**Effective Date**: October 11, 2025

---

## Introduction

MealAdvisor ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use the MealAdvisor iOS application (the "App").

By using MealAdvisor, you agree to the collection and use of information in accordance with this policy.

---

## Information We Collect

### 1. **Information You Provide** (Optional)

MealAdvisor works without requiring you to create an account. However, if you choose to sign in, we may collect:

- **Email Address**: When you sign in with Apple, Google, or email
- **Display Name**: From your Apple or Google account (if provided)
- **Account Credentials**: Managed securely by Apple/Google authentication services

### 2. **Automatically Collected Information**

To provide core functionality, we collect:

- **Device Identifier**: A unique, anonymous device ID for usage tracking (if not signed in)
- **Meal Preferences**: Your dietary restrictions, cuisine preferences, cooking time preferences, and serving size
- **Meal Ratings**: Your likes and dislikes for meal suggestions
- **Usage Data**: Number of meal suggestions requested per day (for free tier quota enforcement)
- **App Usage Analytics**: Feature usage, suggestion generation times, error events (opt-in, stored locally only)

### 3. **Technical Information**

- **App Version**: For debugging and support purposes
- **Device Type**: iOS version and device model (for compatibility)
- **Network Status**: Online/offline state (for offline functionality)

---

## How We Use Your Information

We use the collected information to:

1. **Provide Meal Suggestions**: Generate personalized meal recommendations based on your preferences
2. **Sync Across Devices**: If you sign in, sync your preferences and favorites across your devices
3. **Enforce Usage Limits**: Track free tier usage quota (5 suggestions per day for free users, unlimited for Premium)
4. **Improve User Experience**: Avoid suggesting recently shown or disliked meals
5. **Process Subscriptions**: Manage Premium subscription status via Apple's StoreKit
6. **App Improvement**: Analyze anonymized usage patterns to improve features (opt-in only)

---

## Data Storage and Security

### **Local Storage** (On Your Device)
- Meal preferences
- Meal ratings (likes/dislikes)
- Cached meal suggestions (for offline use)
- Usage quota counter
- Analytics events (if enabled)

**Security**: Data is stored securely on your device and protected by iOS encryption.

### **Cloud Storage** (Optional - Only if Signed In)
- User preferences
- Favorite meals
- Usage tracking (for cross-device sync)

**Security**: All cloud data is encrypted in transit (HTTPS) and at rest. We use Supabase, a secure PostgreSQL database with row-level security policies.

### **Data Retention**
- **Local Data**: Remains on your device until you delete the app or clear data
- **Cloud Data**: Retained while your account is active, deleted within 30 days of account deletion
- **Analytics Data**: Anonymized and retained for up to 12 months

---

## Third-Party Services

We use the following third-party services:

### 1. **Supabase** (Backend & Database)
- **Purpose**: Store user preferences, favorites, and usage data (only if signed in)
- **Data Shared**: Email, user ID, preferences, favorites
- **Privacy Policy**: [https://supabase.com/privacy](https://supabase.com/privacy)

### 2. **Unsplash** (Food Photography)
- **Purpose**: Fetch high-quality food images for meal suggestions
- **Data Shared**: Search queries (meal names, cuisine types)
- **Privacy Policy**: [https://unsplash.com/privacy](https://unsplash.com/privacy)
- **Note**: No personal information shared, only meal-related search terms

### 3. **Sign in with Apple**
- **Purpose**: Optional authentication (if you choose to sign in)
- **Data Shared**: Email (optional), Apple User ID
- **Privacy Policy**: [https://www.apple.com/legal/privacy/](https://www.apple.com/legal/privacy/)

### 4. **Google Sign-In**
- **Purpose**: Optional authentication (if you choose to sign in)
- **Data Shared**: Email, Google User ID, profile name
- **Privacy Policy**: [https://policies.google.com/privacy](https://policies.google.com/privacy)

### 5. **Apple StoreKit** (In-App Purchases)
- **Purpose**: Process Premium subscription purchases
- **Data Shared**: Purchase transactions (managed by Apple)
- **Privacy Policy**: [https://www.apple.com/legal/privacy/](https://www.apple.com/legal/privacy/)

---

## Your Privacy Rights

You have the following rights regarding your data:

### **Access & Export**
- View all your preferences in the Settings screen
- Export your data by contacting us

### **Deletion**
- Clear ratings: Settings → Clear Ratings
- Reset preferences: Settings → Reset Preferences
- Delete account: Settings → Sign Out (cloud data deleted within 30 days)
- Delete app: All local data is removed immediately

### **Opt-Out**
- Analytics: Settings → Privacy → Disable Analytics
- Authentication: Use app without signing in (fully functional)

### **Data Portability**
- Your preferences and favorites are stored in standard JSON format
- Contact us to request a copy of your data

---

## Children's Privacy

MealAdvisor is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us, and we will delete such information.

---

## International Users

MealAdvisor is available worldwide. By using the App, you consent to the transfer and processing of your data in accordance with this Privacy Policy, regardless of your location.

**Data Storage Location**: United States (Supabase servers)

---

## Analytics and Tracking

### **What We Track** (Opt-In):
- Meal suggestions generated
- Recipes viewed
- Delivery app selections
- Premium subscription events
- Error events (for debugging)

### **What We DON'T Track**:
- Third-party advertising
- Cross-app tracking
- Location data
- Browsing history outside the app

### **How to Opt-Out**:
Settings → Privacy → Disable Analytics

---

## Cookies and Similar Technologies

MealAdvisor does not use cookies. We use local device storage (UserDefaults and file caching) to save your preferences and improve performance.

---

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of significant changes by:
- Updating the "Last Updated" date at the top of this policy
- Displaying an in-app notification (for major changes)

Continued use of the App after changes constitutes acceptance of the updated policy.

---

## California Privacy Rights (CCPA)

If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):

- **Right to Know**: Request information about data we collect
- **Right to Delete**: Request deletion of your personal information
- **Right to Opt-Out**: Opt-out of data sales (Note: We do not sell your data)
- **Non-Discrimination**: We will not discriminate against you for exercising your rights

To exercise these rights, contact us at the email below.

---

## GDPR Compliance (EU Users)

If you are located in the European Economic Area (EEA), you have rights under the General Data Protection Regulation (GDPR):

- **Legal Basis**: Consent, contract performance, legitimate interests
- **Data Controller**: MealAdvisor (contact information below)
- **Data Processor**: Supabase (for cloud storage)
- **Right to Access**: Request a copy of your data
- **Right to Rectification**: Correct inaccurate data
- **Right to Erasure**: Request deletion of your data
- **Right to Portability**: Receive your data in a portable format
- **Right to Object**: Object to data processing
- **Right to Withdraw Consent**: Withdraw consent at any time

To exercise these rights, contact us at the email below.

---

## Data Security

We implement industry-standard security measures to protect your information:

- **Encryption**: All data transmitted between your device and our servers is encrypted using HTTPS/TLS
- **Secure Storage**: Cloud data is encrypted at rest in Supabase
- **Authentication**: Sign in with Apple and Google use industry-standard OAuth 2.0
- **Access Control**: Row-level security policies ensure users can only access their own data
- **No Data Selling**: We never sell, rent, or trade your personal information

However, no method of transmission or storage is 100% secure. We cannot guarantee absolute security.

---

## Premium Subscriptions

### **Payment Processing**
- Managed entirely by Apple through StoreKit
- We do not store your credit card information
- Subscriptions are billed through your Apple ID account

### **Subscription Data**
- We receive notification of subscription status (active, expired, cancelled)
- We do not receive payment information (handled by Apple)

### **Cancellation**
- Manage subscriptions through iOS Settings → Apple ID → Subscriptions
- Cancelled subscriptions remain active until the end of the billing period

---

## App Permissions

MealAdvisor may request the following permissions:

- **Network Access**: Required to fetch meal suggestions and sync data
- **Notifications** (Optional): For meal reminders (can be disabled in Settings)

We do NOT request:
- ❌ Camera access
- ❌ Photo library access
- ❌ Location services
- ❌ Contacts access
- ❌ Microphone access

---

## Contact Us

If you have questions about this Privacy Policy or your data, please contact us:

**Email**: privacy@mealadvisor.app  
**Response Time**: Within 48 hours

For data deletion requests or GDPR/CCPA inquiries, please include:
- Your email address (if signed in)
- Your device ID (found in Settings → About)
- Nature of your request

---

## Legal

This Privacy Policy is governed by the laws of [Your Country/State].

**Compliance**:
- ✅ Apple App Store Guidelines
- ✅ GDPR (EU users)
- ✅ CCPA (California users)
- ✅ COPPA (no collection from children under 13)

---

## Summary (TL;DR)

- ✅ **Optional Sign-In**: App works without account
- ✅ **Minimal Data**: We collect only what's needed for meal suggestions
- ✅ **No Selling**: We never sell your data
- ✅ **You Control**: Delete data anytime, opt-out of analytics
- ✅ **Secure**: Encryption in transit and at rest
- ✅ **Transparent**: This policy explains everything we do

---

**Last Updated**: October 11, 2025  
**Version**: 1.0

---

*By using MealAdvisor, you acknowledge that you have read and understood this Privacy Policy.*

