# Step 3 — Production and deployment strategies: why blue-green

**What:** bootstrap production: an nginx reverse proxy on **`:8080`** in front of a **blue** environment running v1.

**Why:** we need a real deployment target before we can talk about _how_ to update it.

`cd ~/tutorial && ./deploy/bootstrap.sh`{{exec}}

Open the shop: [http://localhost:8080]({{TRAFFIC_HOST1_8080}}) — blue background, v1.

### The strategy question

How do you put a new version on a running service? The main options ([blue-green deployment, Wikipedia](https://en.wikipedia.org/wiki/Blue%E2%80%93green_deployment)):

We choose **blue-green**: two identical environments; the proxy points at one; releases go to the idle one; a config change flips traffic. Rollback is just flipping back. Its costs — double capacity and database-migration headaches — are part of the reflection in Step 8.

Check what the proxy serves, and note blue's direct port **`:8081`**:

`curl -s localhost:8080/version`{{exec}}

`curl -s localhost:8081/version`{{exec}}

> **Adage 6 — Configuration Is Code.** Which color is live is _configuration_,
> and we manage it exactly like code: a versioned template
> (`deploy/nginx.server.template`), rendered by a script, applied by
> `deploy/flip.sh`. The adages paper warns that untracked, hand-edited config
> ("server drift") is a top source of production outages — Netflix does ~60,000
> config changes a day and still shoots itself in the foot when they are unmanaged.
