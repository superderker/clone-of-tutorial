# Step 8 — Continuous Integration for real: every commit triggers the pipeline

**What:** install a Git hook so that committing a change starts the pipeline automatically, with nobody typing `./ci/pipeline.sh`.

**Why:** until now *you* started every pipeline run. That is a hidden manual step, and manual steps get forgotten, skipped on a busy Friday, or run on a different version than the one that was committed. Continuous Integration means the check happens on **every** change, whether or not anybody remembers to run it. Look back at Figure 1: the arrow from *git commit* into the pipeline is the thing we are building now.

### Install the trigger

A Git hook is a script that Git runs at a defined moment. The `post-commit` hook runs right after every commit:

`cd ~/tutorial && ./ci/install_hook.sh`{{exec}}

You should see `post-commit hook installed: every commit now triggers CI`. Look at what was installed:

`cat ~/tutorial/.git/hooks/post-commit`{{exec}}

The hook runs `./ci/pipeline.sh --ci-only` in the background and writes its output to `.prod/pipeline.log`. Two choices are worth noticing:

- **`--ci-only`:** the hook tests, builds and versions, but it **never deploys**. This is the boundary from Step 2 again. Integrating a change should be automatic and cheap; releasing it to users is a separate decision (Steps 4 and 5). This is "fast to deploy, slow to release" (Adage 3) applied to the trigger.
- **Background and log file:** the commit returns immediately instead of making the developer wait for the build. The log is how you see what happened afterwards, and it lives in `.prod/` because that folder is excluded from Git. A log in the repo root would be committed by `new_change.sh`.

### Make a change and watch it happen

Commit a new version. Do **not** run the pipeline yourself:

`cd ~/tutorial && ./new_change.sh 6`{{exec}}

The commit finishes straight away. Now follow the log:

`tail -f ~/tutorial/.prod/pipeline.log`{{exec}}

Within a few seconds you will see the same stages as in Step 2 (`[1/4] TEST`, `[2/4] BUILD`, `[3/4] VERSION`) run on their own, ending in `CI COMPLETE | app:6 tested, built and versioned`. Press **Ctrl+C** to stop following the log once you see that line.

Confirm the artifact exists and that production did not move:

`docker images app`{{exec}}

`curl -s localhost:8080/version; echo`{{exec}}

You should see `app:6` in the image list, while users are still on v3 served by blue. A commit produced a tested, versioned artifact and changed nothing in production, because deployment stays a separate decision.

> **If CHECK says no:** the build takes some seconds. Wait until `tail -f` has printed `CI COMPLETE | app:6`, then click CHECK.

### Why this is only a first version

This hook is a teaching device. It shows the mechanism, but it is weaker than a real CI system in ways worth knowing:

- **It is not shared.** `.git/hooks` is not part of the repository, so a teammate who clones it does not get the hook. A real setup keeps the trigger on a server that everyone's commits reach.
- **It runs on the developer's machine.** "It works on my machine" is exactly what a CI server exists to remove. A dedicated build server provides a clean, identical environment for every run.
- **It can be bypassed.** `git commit --no-verify` skips some hooks, and a developer who never installed it skips all of them. A server-side trigger cannot be skipped by one person.
- **It queues nothing.** Two commits in quick succession start two overlapping runs. Real CI servers queue or cancel runs.

Real platforms such as Jenkins or GitHub Actions replace the local hook with a **webhook**: the Git server notifies the CI server that a push happened, and the CI server runs the pipeline on its own clean machine. The principle is the same one you just saw, with the trigger moved somewhere reliable.

**Adage 2 — The Cost of Change Is Dead** needs this step. Small, frequent changes are only cheap if checking each one costs nobody any effort. When integration is automatic, a broken commit is found within seconds of being made, while the developer still remembers what they changed.

Click **CHECK**, then continue to the final reflection.