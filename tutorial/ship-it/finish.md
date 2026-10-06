# Recap

You built and operated a small **continuous delivery/deployment system** and experienced the difference between testing, delivering, releasing, and recovering from failure.

## What was built

| Concept                        | Demonstrated it when...                                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Continuous Integration**     | v2 was tested and built as part of the CI pipeline (Step 2).                                                        |
| **Continuous Delivery**        | v2 was deployed and verified, but waited for manual approval before users received it (Step 4).                     |
| **Continuous Deployment**      | v3 passed all automated checks and went live without human intervention (Step 5).                                   |
| **Blue-green deployment**      | Traffic was switched proxy-side between two environments (Steps 3–5).                                               |
| **Telemetry-gated release**    | The broken v4 passed unit tests but failed its production-like health check and was automatically aborted (Step 6). |
| **Dark launch / feature flag** | v5's beta feature was deployed before being exposed to users (Step 7).                                              |
| **Instant rollback**           | One command switched traffic back to the previous version (Step 7).                                                 |

## The DevOps principles you encountered

Throughout the tutorial, you worked with all ten adages from _The Top 10 Adages in Continuous Deployment_:

1. **Every Feature Is an Experiment** — telemetry and automated verification.
2. **The Cost of Change Is Dead** — small, frequent, recoverable releases.
3. **Be Fast to Deploy but Slow to Release** — deployment and release are separate decisions.
4. **Invest for Survival** — automation replaces repetitive manual work.
5. **You Are the Support Person** — teams own their software throughout its lifecycle.
6. **Configuration Is Code** — deployment configuration is versioned and reproducible.
7. **Comfort the Customer with Discomfort** — not every customer or environment can move at the same speed.
8. **Retrospectives** — failures become input for improving the system.
9. **Invite Privacy and Security In** — security should be part of the pipeline.
10. **Ready or Not, Here It Comes** — frequent automated delivery enables rapid feedback and release.

## Where to go next

The system you built is intentionally small. Here are some ways to extend it:

- **Add canary deployment:** send a small percentage of traffic to the new version before performing the full traffic switch.
- **Add a database:** introduce an **expand/contract migration** and explore why stateful systems make blue-green deployment more difficult.
- **Move to Kubernetes:** rebuild the architecture using Kubernetes **Deployments** and **Services**.
- **Add DevSecOps controls:** introduce dependency vulnerability scanning, container-image scanning, and image signing as automated pipeline stages (Adage 9).
- **Add observability:** collect application metrics and logs and use them to make automated deployment decisions.

The important lesson is not that continuous deployment is always the right answer. The lesson is that **automation, small changes, automated verification, controlled release, and fast recovery allow teams to choose their release strategy based on risk rather than habit.**

## Sources

- [An Introduction to Continuous Integration, Delivery and Deployment](https://www.digitalocean.com/community/tutorials/an-introduction-to-continuous-integration-delivery-and-deployment)
- _The Top 10 Adages in Continuous Deployment_ — Parnin et al.
- [Continuous delivery](https://en.wikipedia.org/wiki/Continuous_delivery)
- [Continuous deployment](https://en.wikipedia.org/wiki/Continuous_deployment)
- [Blue-green deployment](https://en.wikipedia.org/wiki/Blue%E2%80%93green_deployment)
- [Deployment environment](https://en.wikipedia.org/wiki/Deployment_environment)

**This is the end of the tutorial.**
