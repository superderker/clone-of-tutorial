# Step 8 — Continuous Integration for real: every commit triggers the pipeline

**What:** install a Git hook so that committing a change starts the pipeline automatically, with nobody typing `./ci/pipeline.sh`.

**Why:** until now *you* started every pipeline run. That is a hidden manual step, and manual steps get forgotten, skipped on a busy Friday, or run on a different version than the one that was committed. Continuous Integration means the check happens on **every** change, whether or not anybody remembers to run it. Look back at Figure 1: the arrow from *git commit* into the pipeline is the thing we are building now.

### Install the trigger

A Git hook is a script that Git runs at a defined moment. The `post-commit` hook runs right after every commit. Install it **before** you make the next commit, because a commit made earlier never triggers anything:

`cd ~/tutorial && ./ci/install_hook.sh`{{exec}}

You should see `post-commit hook installed: every commit now triggers CI`. Look at what was installed:

`cat ~/tutorial/.git/hooks/post-commit`{{exec}}

It is two lines: go to the repository root, then run `./ci/pipeline.sh --ci-only`. Two choices are worth noticing:

- **`--ci-only`:** the hook tests, builds and versions, but it **never deploys**. This is the boundary from Step 2 again. Integrating a change should be automatic and cheap; releasing it to users is a separate decision (Steps 4 and 5). This is "fast to deploy, slow to release" (Adage 3) applied to the trigger.
- **Foreground:** the commit waits until the pipeline has finished, so the result appears on your screen right below the commit. Real CI servers run builds in the background and report back afterwards. This hook trades that convenience for visibility, which is what we want while learning.

### Make a change and watch it happen

Commit a new version. Do **not** run the pipeline yourself:

`cd ~/tutorial && ./new_change.sh 6`{{exec}}

The commit takes a few seconds. Right after Git records it, the pipeline output appears by itself: `[1/4] TEST`, `[2/4] BUILD` and `[3/4] VERSION`, the same stages as in Step 2, ending in `CI COMPLETE | app:6 tested, built and versioned`. Then the script prints its own `committed:` line. You typed one command, the commit did the rest.

Confirm that the artifact exists and that production did not move:

`docker images app`{{exec}}

`curl -s localhost:8080/version; echo`{{exec}}

You should see `app:6` in the image list, while users are still on v3 served by blue. A commit produced a tested, versioned artifact and changed nothing in production, because deployment stays a separate decision.

> **If `new_change.sh` says "nothing to commit":** v6 is already committed in this session, so no hook fired. Run `git commit --allow-empty -m "trigger CI"` to see the hook work, or continue with the next version number.

### What happens when CI fails?

A `post-commit` hook runs after the commit exists, so a failing pipeline **cannot undo it**. You see the error, and the commit stays in the history. That is how CI works in general: it does not prevent a bad change from being committed, it tells you within seconds that the change is bad, while you still remember what you did. Teams then treat a red build as the top priority.

### Why this is only a first version

This hook is a teaching device. It shows the mechanism, but it is weaker than a real CI system in ways worth knowing:

- **It is not shared.** `.git/hooks` is not part of the repository, so a teammate who clones it does not get the hook. A real setup keeps the trigger on a server that everyone's commits reach.
- **It runs on the developer's machine.** "It works on my machine" is exactly what a CI server exists to remove. A dedicated build server provides a clean, identical environment for every run.
- **It can be skipped.** A developer who never installed it, or who deletes it, bypasses CI entirely. A server-side trigger cannot be switched off by one person.
- **It blocks the developer.** The commit waits for the build. With a slow test suite, that becomes unbearable, and it is one reason real CI runs on separate machines.

Real platforms such as Jenkins or GitHub Actions replace the local hook with a **webhook**: the Git server notifies the CI server that a push happened, and the CI server runs the pipeline on its own clean machine. The principle is the same one you just saw, with the trigger moved somewhere reliable.

**Adage 2 — The Cost of Change Is Dead** needs this step. Small, frequent changes are only cheap if checking each one costs nobody any effort. When integration is automatic, a broken commit is found within seconds of being made.

Click **CHECK**, then continue to the final reflection.