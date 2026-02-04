# APP STORE COMPLIANCE SPECIFICATION

**Authority:** PRODUCT_SPEC | LEGAL_FRAMEWORK_SPEC
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. Apple App Store Requirements

### 1.1 Privacy Manifest (Required since Spring 2024)
- `NSPrivacyTrackedDomains`: List all third-party domains (Stripe, Firebase, Mixpanel/PostHog, Sentry, Google Maps)
- `NSPrivacyTrackingDomains`: Empty (we do not track users across apps)
- `NSPrivacyCollectedDataTypes`: Location (precise, for task matching), contacts (not collected), identifiers (user ID), usage data (analytics events)
- `NSPrivacyAccessedAPITypes`: UserDefaults (app preferences), file timestamp (cache management)
- App Tracking Transparency (ATT): NOT required (no cross-app tracking). If analytics SDK uses IDFA in future → ATT prompt required.

### 1.2 In-App Purchase Exemption
HustleXP facilitates payments for **physical, real-world services** (task completion). Per Apple's App Store Review Guideline 3.1.3(e), payments for physical goods and services rendered outside the app do NOT require Apple's IAP system.

**Defense documentation:**
- All tasks are physical/in-person services (yard work, delivery, assembly, etc.)
- Payment is for labor performed in the real world, not digital content
- Stripe Connect processes payments between poster and worker for completed physical tasks
- No digital goods, subscriptions, or virtual currency are sold

### 1.3 Content Rating
- Rating: 12+ (Infrequent/Mild Mature/Suggestive Themes)
- Justification: Task descriptions may reference adult contexts (bar setup, moving). Content moderation prevents explicit content.
- No gambling, horror, or violence

### 1.4 Required Metadata
- Support URL: `support.hustlexp.com` (CUSTOMER_SUPPORT_SPEC)
- Privacy Policy URL: `hustlexp.com/privacy` (LEGAL_FRAMEWORK_SPEC)
- Terms of Service URL: `hustlexp.com/terms` (LEGAL_FRAMEWORK_SPEC)

---

## §2. Google Play Requirements

### 2.1 Data Safety Section
| Data Type | Collected | Shared | Purpose |
|---|---|---|---|
| Name | Yes | No | Account identity |
| Email | Yes | No | Authentication, communication |
| Phone | Yes | No | Identity verification (§23) |
| Location (precise) | Yes | No | Task matching, navigation |
| Photos | Yes | No | Proof submission, profile |
| Payment info | Yes | With Stripe | Task payments |
| App activity | Yes | No | Analytics |
| Device identifiers | Yes | No | Sybil prevention |

### 2.2 Permissions Justification
- `ACCESS_FINE_LOCATION`: Required for task matching and en-route navigation
- `CAMERA`: Required for proof photo submission
- `POST_NOTIFICATIONS`: Task updates, messages, status changes
- `READ_EXTERNAL_STORAGE` (if needed): Proof photo selection from gallery

### 2.3 Content Rating (IARC)
- Category: Social / Marketplace
- Interactive elements: Users interact, shares location, digital purchases (Stripe, not IAP)

---

## §3. Review Preparation Checklist

**Pre-submission (both stores):**
- [ ] Demo account credentials provided in review notes
- [ ] All screens functional (no placeholder content)
- [ ] Privacy Policy live at URL
- [ ] Terms of Service live at URL
- [ ] Support contact functional
- [ ] Content moderation active (CONTENT_MODERATION_SPEC)
- [ ] Location permission purpose string clear and accurate
- [ ] Camera permission purpose string clear and accurate
- [ ] No references to "beta" or "test" in production build

**Apple-specific:**
- [ ] Privacy manifest included in Xcode project
- [ ] IAP exemption rationale in review notes
- [ ] All third-party SDKs listed in privacy manifest

**Google-specific:**
- [ ] Data safety form completed in Play Console
- [ ] Target API level meets minimum (current year - 1)
- [ ] 64-bit support confirmed

---

## §4. Post-Launch Compliance

- App store policy changes: Review quarterly
- Privacy manifest updates: On each new SDK addition
- Data safety updates: On each new data collection change
- Content rating review: On major feature additions

---

**END OF APP_STORE_COMPLIANCE_SPEC v1.0.0**
