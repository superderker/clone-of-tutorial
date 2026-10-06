# Step 7 — Dark launches and instant rollback

**What:** ship v5 with a new feature **flagged on** — deployed before it is released — then practice the fastest rollback in the business.

**Why:** _Adage 3_ again, now with a real feature flag, plus _Adage 2_. A feature can be deployed to an environment before it is exposed to users, while blue-green deployment makes it possible to reverse a release quickly.

Commit v5 with the beta feature enabled:

`cd ~/tutorial && ./new_change.sh 5 --beta`{{exec}}

`./ci/pipeline.sh`{{exec}}

Before the flip, the pipeline verified green directly. Here is the dark-launch idea: the beta feature was already reachable on the idle environment (`curl -s localhost:8082/beta` would have worked during deployment) while users saw nothing — **deployed, not yet released**.

Now it is live: open [the shop]({{TRAFFIC_HOST1_8080}}) and follow the **try the beta** link, or:

`curl -s localhost:8080/beta`{{exec}}

Now imagine the beta causes a problem: conversion drops, or legal asks for it to be removed. In a stop-the-world deployment model, you might need to redeploy or restore files while the problem is active. Here, rollback is a **one-second proxy flip** to the previous environment:

`./deploy/rollback.sh`{{exec}}

`curl -s localhost:8080/version`{{exec}}

`curl -s localhost:8080/beta`{{exec}}

v3 again, beta gone.

Two things made this cheap:

- **Immutable artifacts:** `app:3` still exists, untouched.
- **Config-as-code flip:** the "rollback" is one rendered nginx template plus a reload.

Seeing not found in the shop tab? Your browser is still on the /beta page — and v3 doesn't have that route. That's the rollback working: the feature is gone. Head back to the shop root (/) and you'll see v3 alive and well or simply click on [the shop]({{TRAFFIC_HOST1_8080}}).

> **Adage 2 — The Cost of Change Is Dead.** Boehm's curve (fixes get ~10x more
> expensive per phase) flattens when development and production happen "the same
> day by the same person": you released v5 five minutes ago, you remember exactly
> what it does, and reverting it costs one command. Google's experience in the
> paper: small change scope makes pinpointing culprits fast.
>
> Note the honest limitation printed by `rollback.sh` when no previous release
> survives: _roll forward_ (fix and redeploy) is the only option — which is only
> acceptable because your pipeline is fast.
