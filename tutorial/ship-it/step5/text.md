# Step 5 — Continuous Deployment: remove the gate

**What:** run the same pipeline with one policy change.

**Why:** [Continuous Deployment](https://en.wikipedia.org/wiki/Continuous_deployment) extends continuous delivery by removing the manual release gate: every change that passes all required automated checks can be deployed to production automatically. Look how thin the technical difference is:
```bash
  if [ "${APPROVAL:-auto}" = "manual" ]; then
    echo "$IDLE $V" > "$CANDIDATE"   # park the verified candidate...
    exit 0                           # ...and wait for ./deploy/approve.sh
  fi
  ./deploy/flip.sh "$IDLE"           # auto: release immediately
```
No new deployment machinery is required — the gate is a **policy decision**, not a separate technology. That is why the DigitalOcean article describes continuous deployment as "one step further" than continuous delivery.

Commit v3 and let it flow through, untouched by human hands:

`cd ~/tutorial && ./new_change.sh 3`{{exec}}

`./ci/pipeline.sh`{{exec}}

(`APPROVAL` defaults to `auto`.) Observe: deploy to blue → verify on `:8081` → **flip without asking** → re-verify through the proxy → done.

Refresh [the shop]({{TRAFFIC_HOST1_8080}}): blue background, v3

`curl -s localhost:8080/version`{{exec}}

> **Why would anyone accept that risk?** Because the gate is not removed — it is
> _moved into the automation_. The tests and smoke checks now carry the trust a
> human used to carry. The adages paper reports the potential payoff: faster
> feature delivery, higher measured quality, and less release-deadline stress.
> But this approach depends on strong automated tests and reliable deployment
> checks. Without them, removing the human gate can simply make failures reach
> production faster.
