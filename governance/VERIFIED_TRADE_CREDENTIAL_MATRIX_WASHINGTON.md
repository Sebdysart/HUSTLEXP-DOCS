# Verified Trade Credential Matrix — Washington Launch

**Version:** 1.0.0  
**Decision status:** LOCKED verification architecture; OPEN — LEGAL/INSURANCE for final sufficiency  
**Launch geography:** Washington, initially Bellevue and Redmond  
**Production effect:** NONE  
**Production payment creation:** FROZEN

## Rule

Google, public reviews, websites, and other reputation signals may identify a `TRADE_PROSPECT` or support `REPUTATION_QUALIFIED`. They never grant `CATEGORY_ELIGIBLE`, `PAYMENT_ELIGIBLE`, or `TASK_ELIGIBLE`.

Official records, the exact regulated scope, provider-business evidence, named-worker or crew evidence, active restrictions, insurance policy, jurisdiction, and task policy determine eligibility. A passing record is time-bound and must be rechecked at assignment.

## Common business evidence

Every `VERIFIED_TRADE_BUSINESS` record must bind:

- legal and trade names plus UBI;
- responsible principals and official business identity;
- active contractor or trade license/registration numbers and exact specialties;
- bond and required liability-insurance evidence;
- workers' compensation status when applicable;
- citations, infractions, suspensions, restrictions, and bond claims;
- named administrator, master, designated professional, certified worker, or eligible crew where required;
- service area and jurisdiction;
- expiration, last-verified time, source, verifier, and next-refresh time;
- category-specific eligibility separately from task-specific eligibility.

## Initial category matrix

| Category | Minimum official business authority | Worker or crew evidence | Scope constraints before task eligibility |
| --- | --- | --- | --- |
| Electrical | Active Washington electrical contractor license, UBI, assigned administrator or master electrician, required bond, and workers' compensation status when applicable | Properly certified electricians for the assigned work and specialty | Exact electrical specialty, permit/inspection needs, property conditions, task geography, and emergency exclusion |
| Plumbing | Active Washington plumbing contractor license, UBI, designated certified plumber, required bond and liability insurance, and workers' compensation status when applicable | Properly certified plumber appropriate to the scope | Exact plumbing certification/specialty, permit/inspection needs, task geography, and emergency exclusion |
| HVAC | Active Washington general or applicable specialty contractor registration with UBI, bond, liability insurance, and workers' compensation status when applicable | Named eligible workers plus any electrical, plumbing, refrigeration, boiler, or other scope-specific credentials required for the task | Decompose the job by regulated scope; no generic “HVAC approved” flag may authorize electrical, plumbing, gas, refrigerant, boiler, or permit work |
| Roofing | Active Washington general or roofing specialty contractor registration with UBI, bond, liability insurance, and workers' compensation status when applicable | Named eligible business crew and any task-required training or certification | Roof type, height/fall exposure, structural ambiguity, permit needs, weather, property conditions, and prohibited hazardous-material scope |
| General contractor / remodel | Active Washington general contractor registration with UBI, bond, liability insurance, and workers' compensation status when applicable | Named project-responsible business and eligible subcontractor or trade-business records | Project and permit topology; plumbing and electrical work routes only to separately licensed businesses; HustleXP does not superintend or become the construction contractor without separate authority |

## Verification state

```text
TRADE_PROSPECT
→ REPUTATION_QUALIFIED
→ CREDENTIAL_VERIFICATION
→ T4_VERIFIED_TRADE_BUSINESS
→ CATEGORY_ELIGIBLE
→ PAYMENT_ELIGIBLE
→ TASK_ELIGIBLE
```

No later state may be inferred from an earlier one. `PAYMENT_ELIGIBLE` is processor- and topology-specific. `TASK_ELIGIBLE` is occurrence-specific.

## Official Washington sources

- [L&I Verify a Contractor, Tradesperson or Business](https://www.lni.wa.gov/licensing-permits/contractors/hiring-a-contractor/verify-contractor-tradesperson-business)
- [L&I Electrical Contractor requirements](https://www.lni.wa.gov/licensing-permits/electrical/electrical-licensing-exams-education/electrical-contractor)
- [L&I Licensed Plumbing Contractor requirements](https://lni.wa.gov/licensing-permits/plumbing/licensed-plumbing-contractor/)
- [L&I Register as a Contractor](https://lni.wa.gov/licensing-permits/contractors/register-as-a-contractor/index)
- [RCW 18.27.010 — contractor and general-contractor definitions](https://app.leg.wa.gov/rcw/default.aspx?cite=18.27.010)

This matrix is not legal advice and does not claim that these fields alone are sufficient. Counsel, insurance, processor, local-permit, and category policies may add stricter requirements.

