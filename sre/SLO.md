# ABC Technologies – Service Level Objectives (SLOs)

| | |
|---|---|
| **Service** | ABC Technologies web application (Java servlet on Tomcat) |
| **Platform** | AWS EKS (eu-west-1), 2 replicas, HPA enabled, deployed by Jenkins |
| **Owner** | Shreya Khanduri Bhatt |
| **SLO window** | Rolling 30 days |
| **Status** | Active – implemented in `monitoring/slo-rules.yaml` |

> This is a lab/portfolio service. The targets are set realistically for its architecture,
> not copied from a production system.

---

## 1. Vocabulary

| Term | Meaning | In this project |
|---|---|---|
| **SLI** (Service Level Indicator) | A measurement of service health: good events ÷ total events | Share of successful probes |
| **SLO** (Service Level Objective) | The target an SLI should meet over a time window | 99.5% availability over 30 days |
| **Error budget** | 100% − SLO: how much failure is acceptable | 0.5% of probes (~216 min per 30 days) |
| **Burn rate** | Speed of error budget consumption: error rate ÷ error budget | 1 = on budget; 14.4 = budget gone in ~2 days |
| **SLA** | A contract with consequences (e.g. refunds) | Not applicable – no external customers |

---

## 2. User journeys covered

Users of an online retail site need to:

1. **View product details** – the page must load and show data.
2. **Add a product** – the request must succeed.

The SLIs below measure whether these journeys are reachable and fast.

---

## 3. Service Level Indicators (SLIs)

### SLI 1 – Availability

- **Definition:** the proportion of probes that receive a successful HTTP response.
- **Formula:** `successful probes ÷ total probes`
- **Measured by:** Prometheus Blackbox Exporter, metric `probe_success`, probing the application every 30 seconds from inside the cluster.
- **Good event:** probe returns HTTP 2xx.
- **Bad event:** timeout, connection error, or non-2xx response.

### SLI 2 – Latency

- **Definition:** the proportion of probes that complete in under 300 ms.
- **Formula:** `probes faster than 300 ms ÷ total probes`
- **Measured by:** Blackbox metric `probe_duration_seconds`.

---

## 4. Service Level Objectives (SLOs)

| SLI | Target | Window | Error budget |
|---|---|---|---|
| Availability | **99.5%** | 30 days | 0.5% ≈ **216 minutes** (about 3.6 hours) of failed probes |
| Latency (< 300 ms) | **95%** | 30 days | 5% of probes may be slower |

### Error budget in numbers (availability)

- 30 days = 43,200 minutes
- Budget: 0.5% × 43,200 = **216 minutes**
- Probes: one every 30 s ≈ 86,400 per 30 days → budget ≈ **432 failed probes**

---

## 5. Why these targets

| SLO | Max downtime per 30 days | Typical requirement |
|---|---|---|
| 99% | 7.2 hours | Single instance acceptable |
| **99.5%** | **3.6 hours** | **2+ replicas, health probes, safe rolling deployments** |
| 99.9% | 43 minutes | Multi-AZ, automated rollback, mature on-call |
| 99.99% | 4.3 minutes | Multi-region, extensive automation |

**99.5% was chosen because** the service runs in one region on a single EKS cluster with two
replicas, an HPA and rolling updates. That architecture can realistically meet 99.5%.
A stricter target such as 99.9% would require multi-AZ node placement, faster automated
rollback and a staffed on-call process, which are beyond what this project provides.
**The latency target of 95% under 300 ms** is a starting point, to be revisited
once real baseline data has been collected.

---

## 6. How it is implemented

| Component | File |
|---|---|
| Synthetic probe of the application | `monitoring/abc-probe.yaml` |
| SLI recording rules, burn-rate rules and alerts | `monitoring/slo-rules.yaml` |
| Dashboard queries | `monitoring/grafana-queries.md` |
| What to do when budget is low | `sre/error-budget-policy.md` |

---

## 7. Known limitations

- **Synthetic, not real user traffic.** Probes cannot see errors that affect only some users or some request types.
- **Single probe location.** The probe runs inside the cluster, so it cannot detect problems between users and the cluster (DNS, load balancer, internet path).
- **Low volume.** Probe-based ratios are coarse; production services would use request-based SLIs from application metrics.
- **Retention.** A true 30-day budget view needs 30 days of Prometheus data. Until that history exists, remaining-budget values reflect only the data collected so far.

## 8. Planned improvements

1. Instrument the application with request-level metrics (request count, status code, latency histogram) and move SLIs from probes to real requests.
2. Gate Jenkins deployments on remaining error budget.
3. Add runbooks for each alert and write postmortems for injected failures.
4. Review these targets every quarter or after any significant incident.
