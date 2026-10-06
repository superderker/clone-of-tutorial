# Step 4 — Continuous Delivery: the manual gate

**What:** release v2 with `APPROVAL=manual`. The pipeline deploys and verifies the release candidate, then **stops and waits for a human**.

**Why:** this is the defining distinction of [Continuous Delivery](https://en.wikipedia.org/wiki/Continuous_delivery): every change is kept in a releasable state, but deployment to production can still require explicit approval. The DigitalOcean reading draws the distinction clearly: CI produces a built and tested artifact; continuous delivery extends this into a release-ready state, while continuous deployment automates the final production step.

Run the pipeline in delivery mode:

`cd ~/tutorial && APPROVAL=manual ./ci/pipeline.sh`{{exec}}

Watch it: test → build (cached) → deploy v2 to **green** → smoke-test green **directly on `:8082`** → then print `RELEASE CANDIDATE READY` and stop.

Crucially, **users still see v1**:

`curl -s localhost:8080/version`{{exec}}

But you — the release engineer — can inspect the candidate on its private port:

`curl -s localhost:8082/version`{{exec}}

This idle slot is our _staging_ tier: production-like, but receiving zero user traffic.

Satisfied? Approve the release like a human pressing the button:

`./deploy/approve.sh`{{exec}}

Refresh [the shop]({{TRAFFIC_HOST1_8080}}): green background, v2 — and you never saw an error page, because traffic moved only _after_ the candidate was verified.

> **Adage 3 — Be Fast to Deploy but Slow to Release.** v2 was _deployed_ to
> production infrastructure (green runs in the production cluster) while not yet
> _released_ to users. Deployment and release are separate decisions — this is
> what makes dark launches and feature flags possible (Step 7).
