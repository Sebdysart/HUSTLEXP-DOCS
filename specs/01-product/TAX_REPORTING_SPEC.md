# TAX REPORTING SPECIFICATION

**Authority:** PRODUCT_SPEC §24 | API_CONTRACT tax.* endpoints | schema.sql v1.5.0
**Status:** v1.0 — Launch-ready specification

---

## 1. Legal Obligation

HustleXP operates as a marketplace facilitating payments to independent contractors. Under IRS regulations:
- **Form 1099-NEC** must be issued to any worker earning **≥$600** in a calendar year
- Platform must collect **W-9 (or W-9 equivalent data)** from workers before first payout
- 1099-NEC forms must be filed with IRS and delivered to workers by **January 31** of the following year

## 2. W-9 Collection

### 2.1 Trigger
W-9 data collection is triggered during **Stripe Connect onboarding**. Stripe collects:
- Legal name
- SSN or EIN
- Address
- Business type (individual/sole proprietor for most workers)

### 2.2 Verification
- Stripe performs TIN matching against IRS database
- If TIN match fails: worker notified, 30-day grace period to correct
- After 30 days unresolved: **backup withholding at 24%** applied to future payouts
- Worker cannot receive new payouts until TIN issue resolved

### 2.3 Storage
- W-9 data stored by Stripe (not in HustleXP database)
- HustleXP stores only: `w9_status` ('NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'FAILED')
- No SSN/TIN stored in HustleXP systems

## 3. 1099-NEC Generation

### 3.1 Annual Process (January)

| Step | Deadline | Action |
|------|----------|--------|
| 1 | Jan 5 | Automated job calculates annual earnings per worker |
| 2 | Jan 10 | Generate 1099-NEC for workers with earnings ≥ $600 |
| 3 | Jan 15 | 1099-NEC available in worker dashboard for review |
| 4 | Jan 31 | File with IRS via Stripe Tax Reporting API |
| 5 | Jan 31 | Deliver to workers (email + in-app download) |

### 3.2 Earnings Calculation
- Gross earnings = SUM of all escrow releases to worker in calendar year
- Amount reported on 1099-NEC = gross earnings (before platform fees)
- Platform fees are the platform's revenue, not the worker's deduction
- Worker is responsible for their own business expense deductions

### 3.3 Stripe Tax Reporting API
- Use `stripe.tax.forms.create()` for 1099-NEC generation
- Stripe handles IRS e-filing
- Stripe provides PDF download URLs for worker access
- `tax_documents` table tracks forms per worker per year

## 4. Worker Tax Dashboard

Workers can access from Settings → Tax Documents:
- Current year earnings-to-date
- 1099-NEC threshold tracker ($600 progress bar)
- Historical 1099 forms by year (PDF download)
- W-9 status indicator
- Link to Stripe dashboard for W-9 updates

## 5. State-Level Requirements

v1 scope: Federal 1099-NEC only. State-level requirements (varies by state) are deferred to v1.5.

Known requirements for launch states:
- California: Form 1099-NEC copy to CA FTB if ≥$600
- New York: Form 1099-NEC copy to NY DTF if ≥$600

## 6. Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| TAX-1 | No payout without W-9 data on file | Stripe Connect blocks transfers |
| TAX-2 | 1099-NEC filed for all workers ≥$600/year | Annual batch job + audit |
| TAX-3 | No SSN/TIN stored in HustleXP database | Stripe stores all PII |
| TAX-4 | Backup withholding applied on TIN mismatch | Stripe handles automatically |

---

**END OF TAX_REPORTING_SPEC v1.0**
