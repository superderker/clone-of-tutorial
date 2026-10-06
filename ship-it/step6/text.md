# Step 6 — The safety net: a bad release never reaches users

**What:** ship a release that passes unit tests but is broken _in production configuration_, and watch the pipeline refuse to release it.

**Why:** this is the moment that justifies the entire architecture. Continuous Deployment is only useful when automated checks can prevent unsafe releases from reaching users.

Commit v4 with a simulated bad production configuration (`--broken` creates a `BROKEN` marker file — think: a wrong database URL or a malformed JSON setting):

`cd ~/tutorial && ./new_change.sh 4 --broken`{{exec}}

`./ci/pipeline.sh`{{exec}}

Watch closely:

1. **Unit tests pass.** The code is fine; the _configuration_ is poisoned. Classic.

2. The image builds. v4 deploys to the idle color (green).

3. The smoke test checks `/health` on green directly → **500 Unhealthy**.

4. The pipeline **aborts**, deletes the broken environment, and exits with a failure.

Now check what users experienced:

`curl -s localhost:8080/version`{{exec}}

Still v3. **Nobody saw anything.** The failure cost you one minute, not an incident.

> **Adage 1 — Every Feature Is an Experiment** (telemetry-first): the pipeline
> _decided_ using live health data, not hope. The paper's companies stream
> metrics centrally and let automation react — our `smoke.sh` is a toy version
> of the same idea. It also shows why "staging" or "baking" exists as a pipeline
> stage: some defects only appear in production-like environments.
>
> **Adage 5 — You Are the Support Person.** When this pipeline fails at 3 a.m.,
> the person who committed v4 gets the alert — not a separate ops team.
> Cradle-to-grave ownership is what keeps rapid deployment honest.

The debugging loop is now trivially fast: fix, commit v5, redeploy. Which raises the question for the next step: what if something bad _does_ get through?
