# TAX COMPLIANCE DOCUMENTATION
## 1099-NEC / 1099-K Requirements

### Overview
HustleXP complies with IRS requirements for reporting payments to independent contractors (Hustlers) through Stripe Connect.

### Stripe Connect Integration
- All workers onboarded via **Stripe Connect Express**
- Tax information collected during onboarding:
  - **W-9** for US persons
  - **W-8BEN** for international persons
- Tax ID verification via Stripe

### 1099 Thresholds (IRS 2026)
| Form | Threshold | Trigger |
|------|-----------|---------|
| **1099-NEC** | $600+ in calendar year | Any worker earnings |
| **1099-K** | $20,000+ AND 200+ transactions | Payment card/third-party network |

### Implementation
**File:** `backend/src/services/stripe_connect_service.ts:400-450`

```typescript
// 1099 tracking logic
async trackFor1099(workerId: string, amount: number) {
  const year = new Date().getFullYear();
  await this.db.query(
    `INSERT INTO tax_reporting (worker_id, year, amount, transaction_count)
     VALUES ($1, $2, $3, 1)
     ON CONFLICT (worker_id, year)
     DO UPDATE SET 
       amount = tax_reporting.amount + $3,
       transaction_count = tax_reporting.transaction_count + 1`,
    [workerId, year, amount]
  );
}
```

### Automation
- **Annual Generation:** January 1-31
- **Delivery:** Electronic (email + dashboard) + mail on request
- **IRS Filing:** Electronic via Stripe 1099 API
- **State Filing:** Automatic for states requiring 1099-NEC

### KYC Requirements (FinCEN/Stripe)
| Tier | Requirement | When |
|------|-------------|------|
| **Tier 1** | Identity verification | Before first payout |
| **Tier 2** | Document verification | $1,000+ earnings |
| **Tier 3** | Enhanced due diligence | $10,000+ earnings or suspicious activity |

### AML Monitoring
- Real-time transaction screening
- Suspicious Activity Report (SAR) filing within 30 days
- Office of Foreign Assets Control (OFAC) sanctions screening

### Record Retention
- **Tax records:** 7 years (IRS requirement)
- **KYC documents:** 5 years after account closure
- **Transaction logs:** 10 years (BSA requirement)

### Compliance Contacts
- **Tax questions:** tax-compliance@hustlexp.com
- **KYC/AML:** compliance@hustlexp.com
- **Stripe Connect:** Account manager assigned

---
*Last updated: 2026-02-23*
*Document version: 1.0*
