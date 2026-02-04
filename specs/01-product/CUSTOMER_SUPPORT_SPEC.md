# CUSTOMER SUPPORT SPECIFICATION

**Authority:** API_CONTRACT support.* endpoints | schema.sql v1.5.0 support_tickets
**Status:** v1.0 — Launch-ready specification

---

## 1. Support Channels

### 1.1 v1 Launch Channels

| Channel | Availability | Response SLA |
|---------|-------------|--------------|
| In-app ticket system | 24/7 submission | 24h first response |
| Email (support@hustlexp.com) | 24/7 submission | 24h first response |

### 1.2 Post-Launch (v1.5+)
- In-app live chat (business hours)
- Phone support for ELITE/MASTER tier workers (critical issues)

## 2. Ticket Categories & Routing

| Category | Priority | Auto-Route | SLA |
|----------|----------|------------|-----|
| SAFETY | P0-Critical | Founder alert | 1 hour |
| PAYMENT | P1-High | Operations team | 4 hours |
| DISPUTE | P1-High | Dispute resolution queue | 4 hours |
| TASK | P2-Medium | General support | 12 hours |
| ACCOUNT | P2-Medium | General support | 12 hours |
| OTHER | P3-Low | General support | 24 hours |

### 2.1 Auto-Escalation
- SAFETY tickets: immediate push notification to founder + operations
- Tickets unresolved past 2× SLA: auto-escalate to next tier
- 3+ tickets from same user in 7 days: flag for account review

## 3. Ticket Lifecycle

```
OPEN → IN_PROGRESS → RESOLVED → CLOSED
                  ↓
              ESCALATED → RESOLVED → CLOSED
```

- OPEN: Ticket created, awaiting first response
- IN_PROGRESS: Agent actively working
- RESOLVED: Solution provided, awaiting user confirmation
- CLOSED: User confirmed resolution OR auto-closed after 7 days of no response
- ESCALATED: SLA breached or manual escalation

## 4. Self-Service Resources

Before ticket creation, app presents relevant help articles:

| Issue Type | Self-Service |
|-----------|--------------|
| Payment not received | "Payouts take 2 business days" + earnings dashboard link |
| Task cancelled | Cancellation policy summary + appeal link if applicable |
| Account suspended | Suspension reason + appeal form |
| Can't verify identity | Step-by-step verification guide |
| Dispute filed against me | Dispute process explainer + evidence upload |

## 5. Founder Escalation (v1)

At launch with small team:
- All SAFETY tickets → founder notification within 1 hour
- All tickets unresolved >48h → founder daily digest
- Weekly: ticket volume report, category breakdown, resolution time averages

## 6. Canned Responses

Standardized responses for common issues (stored in admin dashboard):
- Payment delay explanation
- Cancellation policy citation
- Trust tier demotion explanation
- Account suspension reason template
- Dispute process walkthrough

## 7. Feedback Loop

After ticket resolution:
- CSAT survey: "How satisfied are you?" (1-5 scale)
- Optional comment field
- Aggregate CSAT tracked in analytics dashboard
- CSAT < 3.0 for any agent → performance review

## 8. Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| SUPPORT-1 | Every ticket gets first response within SLA | Background job monitors SLA breaches |
| SUPPORT-2 | SAFETY tickets always reach a human within 1h | Push notification + SMS to on-call |
| SUPPORT-3 | No ticket auto-closed without resolution attempt | Agent must add resolution note before close |
| SUPPORT-4 | User can reopen CLOSED ticket within 48h | API: ticket.reopen endpoint |

---

**END OF CUSTOMER_SUPPORT_SPEC v1.0**
