# ABC Technologies – Error Budget Policy

| | |
|---|---|
| **Applies to** | ABC Technologies web application on AWS EKS |
| **Based on** | [`SLO.md`](./SLO.md) |
| **Policy owner** | Shreya Khanduri Bhatt (service owner) |
| **Review cadence** | Quarterly, and after any incident that exhausts budget |

---

## 1. Purpose

An SLO sets how reliable the service should be. The **error budget** is the amount of
unreliability we accept. This policy defines **what we change about how we work** as the
budget is consumed, so that reliability decisions are made by agreed rules in advance
rather than debated during an incident.

---

## 2. Key numbers

| Item | Value |
|---|---|
| Availability SLO | 99.5% over rolling 30 days |
| Error budget | 0.5% ≈ 216 minutes per 30 days |
| Burn rate formula | `error rate ÷ 0.005` |
| Burn rate 1 | Budget is spent exactly at the end of the 30 days (on target) |

**Example:** if 5% of probes are failing, burn rate = 5% ÷ 0.5% = **10**, and the whole
30-day budget would be gone in 3 days.

---

## 3. Burn-rate alerts

Alerts use two windows: a **long window** (the problem is significant) and a
**short window** (the problem is still happening). This avoids both noisy alerts and
alerts that keep firing after recovery.

| Alert | Condition | Budget spent | Severity | Response |
|---|---|---|---|---|
| `ABCErrorBudgetFastBurn` | Burn rate > 14.4 over **1h** and **5m** | 2% of monthly budget per hour; budget exhausted in ~2 days | **Page** | Investigate immediately; consider rollback |
| `ABCErrorBudgetSlowBurn` | Burn rate > 6 over **6h** and **30m** | 5% of monthly budget over 6 hours | **Ticket** | Investigate within the working day |
| `ABCLatencySLOAtRisk` | Under 95% of probes faster than 300 ms for 10 min | Latency budget at risk | **Ticket** | Check load, HPA scaling, recent changes |

**Where the thresholds come from:**
- Fast burn: 14.4 × (1 hour ÷ 720 hours in 30 days) = **2%** of the budget in one hour.
- Slow burn: 6 × (6 hours ÷ 720 hours) = **5%** of the budget in six hours.

These follow the multi-window, multi-burn-rate approach described in the
Google SRE Workbook.

Rules are defined in `monitoring/slo-rules.yaml`.

---

## 4. Actions by error budget remaining

| Budget remaining | State | Required actions |
|---|---|---|
| **More than 50%** | Healthy | Normal release cadence. Spend effort on features and experiments. |
| **25% – 50%** | Caution | Each release needs a second look (review the diff and rollback plan). Check recent changes first when any alert fires. |
| **Below 25%** | At risk | Only small, low-risk changes and reliability fixes are released. Larger changes wait. Prioritise reliability work. |
| **0% (exhausted)** | Frozen | **Release freeze** for new features. Only reliability fixes and security patches ship. Write a postmortem for what consumed the budget. Freeze lifts when the rolling 30-day budget recovers above 25%. |

---

## 5. Exceptions

- **Security fixes** are never blocked by a freeze.
- **Fixes that restore reliability** (rollbacks, capacity changes, bug fixes for the cause of the burn) are always allowed.
- A budget consumed entirely by an **external or infrastructure-wide event** (for example, an AWS regional issue) is recorded and reviewed, but does not by itself trigger a freeze. The decision and reason must be noted in the postmortem.

---

## 6. Decision rights

The service owner declares the budget state, approves exceptions and lifts a freeze.
Every state change and exception is recorded in the postmortem or the pull request
that caused it.

---

## 7. Integration with CI/CD

| Control | Status |
|---|---|
| Burn-rate alerts routed through AlertManager | Implemented |
| Jenkins pre-deploy check that reads remaining budget from Prometheus and blocks or warns below thresholds | **Planned** |
| Post-deploy watch on the SLI with automatic `kubectl rollout undo` on degradation | **Planned** |

---

## 8. Review and improvement

- Revisit SLO targets and thresholds each quarter using real data.
- After every incident that consumes more than 25% of the budget, hold a blameless postmortem and record action items.
- If the budget is never used, the SLO may be too loose; if it is always exhausted, either the SLO is too strict or reliability work is overdue.
