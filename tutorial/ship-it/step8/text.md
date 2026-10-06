# Step 8 — Reflection: when, when not, for whom

**What:** no new machinery — judgment.

**Why:** a DevOps engineer recommends practices; they do not worship them.

### Design decisions made in this tutorial (and why)

- **Shell-script CI instead of Jenkins/GitHub Actions:** those are the right tools in many real environments, but they require additional setup and can hide some of the mechanics we want to learn. Here, the pipeline is short and readable, while the concepts transfer to almost any CI/CD platform.

- **Blue-green over recreate, rolling, or canary:** recreate deployments can cause downtime; rolling deployments can make rollback more involved; canary deployments require additional traffic-splitting and metrics-analysis infrastructure. Blue-green gives us a simple traffic switch and fast rollback at the scale of this tutorial.

- **Smoke tests as the release gate:** the pipeline uses observable health data that automation can act on (Adage 1), rather than relying on a human spot-check after deployment.

- **Configuration as code:** templates, scripts, and Git keep deployment configuration reproducible and versioned instead of relying on hand-edited servers (Adage 6).

### When this approach is useful

This approach works particularly well for web services and SaaS applications with strong automated-test coverage; teams that own features cradle-to-grave (Adage 5); organizations under competitive pressure to deliver continuously (Adage 10 — your competitor ships daily); and teams willing to _invest for survival_ in deployment and testing automation (Adage 4).

### When it is NOT (or not yet)

- **Regulated or safety-critical domains:** some systems require additional validation, approvals, traceability, or controlled release procedures. In these environments, the continuous delivery mode from Step 4 can retain a manual approval gate as an explicit compliance checkpoint.

- **Enterprise/on-premise customers:** _Adage 7 — Comfort the Customer with Discomfort._ Customers that control their own infrastructure may have lengthy integration and validation processes and may not be able to absorb daily updates. A practical compromise can be to release frequently to _your_ cloud while allowing customers to upgrade their _own_ premises on a slower schedule.

- **Stateful schema migrations:** blue-green deployment does not by itself solve the problem of two application versions sharing one database. Safe schema evolution may require expand/contract migrations and backward-compatible application changes, which are deliberately outside this tutorial.

- **Monoliths with thin test coverage:** automating the release gate without sufficient tests does not make releases safer. It can simply automate the path to an outage.

### For whom

Small teams can get significant leverage from automation: one repeatable pipeline can replace many manual release steps. Large organizations can use the same principles to make deployment safer and more consistent at scale. For a solo developer, the continuous delivery mode alone can provide much of the value without requiring fully automatic production deployment.

### Looking back to move forward (Adage 8)

Every release here is associated with a Git commit — your _retrospective_ data already exists:

`git -C ~/tutorial log --oneline`{{exec}}

In real teams, blameless postmortems on pipeline failures can be used to improve the pipeline itself.

And **Adage 9 — Invite Privacy and Security In:** our pipeline has no security scanning or signed artifacts. A production-grade pipeline would typically add security checks such as dependency scanning, vulnerability scanning, and artifact or image signing **inside** the delivery process rather than treating security as an afterthought.

Click **CHECK**, then finish with the recap.
