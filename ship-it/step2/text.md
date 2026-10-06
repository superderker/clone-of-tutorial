# Step 2 — Continuous Integration: every change is built and tested

**What:** make a code change (release v2) and run the **CI portion** of the pipeline.

**Why:** [Continuous Integration](https://www.digitalocean.com/community/tutorials/an-introduction-to-continuous-integration-delivery-and-deployment) means every change merged to the main branch is automatically **built and tested**, so "it works on my machine" stops being a sentence anyone says.

You are the developer now. Commit v2:

`cd ~/tutorial && ./new_change.sh 2`{{exec}}

Now the CI server reacts. `ci/pipeline.sh` is a stand-in for Jenkins/GitHub Actions: it detects the change, runs the unit test suite, and builds an **immutable, versioned artifact** — container image `app:2`:

`./ci/pipeline.sh --ci-only`{{exec}}

Expected: `tests passed`, `image app:2 registered`, `CI COMPLETE`.

Two properties worth noticing:

- **Tests gate the build.** A failing test stops the pipeline _before_ any artifact exists. Try it if you like: `echo "definitely not python" >> app/app.py`, rerun the pipeline, watch it die at stage TEST, then `git checkout -- app/app.py`.

- **The artifact is versioned and immutable.** `app:2` will never change; rollbacks and blue-green switches are cheap because old versions still exist:

`docker images | grep app`{{exec}}

> **Adage 4 — Invest for Survival.** This pipeline script _is_ tooling investment:
> a process captured as runnable, versioned code instead of a wiki page of manual
> steps. The paper notes that at Instagram/Facebook, small tooling teams empower
> much larger feature teams.

So far we only have **CI**: a tested artifact, but nothing running anywhere.

Production does not even exist yet. Next step.
