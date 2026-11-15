# ABC Technologies – Service Level Objectives

## Service and user journeys
Online retail app (Tomcat on EKS). Critical journeys: view product details, add product.

## SLIs
| SLI | Definition | Measured by |
|-----|-----------|-------------|
| Availability | Successful probes / total probes | Blackbox `probe_success`, every 30s |
| Latency | Probes completing under 300 ms / total probes | `probe_duration_seconds` |

## SLOs (rolling 30 days)
| SLI | Target | Error budget |
|-----|--------|--------------|
| Availability | 99.5% | 0.5% = ~216 min (3.6 h) per 30 days |
| Latency (<300 ms) | 95% | 5% of probes |

## Why these numbers
(2–3 sentences: why 99.5% rather than 99.99% for this app, and what it costs
to hit stricter targets: more replicas, multi-AZ, etc. This is what interviewers probe.)

## Known limitations
- Synthetic probes, not real user traffic; they miss per-user errors.
- Single probe location (in-cluster); it can't see failures between users and the cluster.
- Lab traffic volume is low, so ratios are noisy. Production would use request-based SLIs.
