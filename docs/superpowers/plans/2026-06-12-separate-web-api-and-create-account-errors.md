# Separate Web/API and Create Account Errors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the browser bundle base URL separate from the account/login API base URL, route account creation to the API on port `8088`, and show a clear error when the backend is unavailable.

**Architecture:** `init.lua` will expose distinct web and API base URLs so the browser client can still load from `8090` while HTTP validation requests go to `8088`. `modules/client_entergame/createAccount.lua` will keep the current validation flow but surface backend connectivity failures with a modal error box instead of only logging warnings.

**Tech Stack:** Lua client config, OTUI/OTLua account creation module, existing `displayErrorBox` UI helper.

---

### Task 1: Split the base URLs in `init.lua`

**Files:**
- Modify: `init.lua:4-24, 82-84`
- Test: manual Lua inspection via log output / client startup

- [ ] **Step 1: Write the failing check**

```lua
-- current behavior: createAccount points at the browser bundle origin
print(Services.createAccount)
```

- [ ] **Step 2: Run the check to verify it fails**

Run: start the client with `TIBIAOT_PROFILE=vps` and inspect the resolved `Services.createAccount`
Expected: it still resolves to `http://93.188.166.199:8090/clientcreateaccount.php`

- [ ] **Step 3: Write minimal implementation**

```lua
local VPS_WEB_BASE_URL = (os.getenv("TIBIAOT_WEB_BASE_URL") or "http://93.188.166.199:8090"):gsub("/+$", "")
local VPS_API_BASE_URL = (os.getenv("TIBIAOT_API_BASE_URL") or os.getenv("TIBIAOT_VPS_BASE_URL") or os.getenv("TIBIAOT_BASE_URL") or "http://93.188.166.199:8088"):gsub("/+$", "")
local activeApiBaseUrl = CLIENT_PROFILE == "local" and LOCAL_BASE_URL or VPS_API_BASE_URL

Services = buildServices(activeApiBaseUrl)
```

- [ ] **Step 4: Run the check to verify it passes**

Run: start the client with `TIBIAOT_PROFILE=vps`
Expected: `Services.createAccount` resolves to `http://93.188.166.199:8088/clientcreateaccount.php`

- [ ] **Step 5: Commit**

```bash
git add init.lua
git commit -m "fix: separate api base from browser bundle"
```

### Task 2: Surface backend failures in the create-account flow

**Files:**
- Modify: `modules/client_entergame/createAccount.lua:71-99, 107-232, 479-500, 668-674`
- Test: manual client interaction on the account-creation window

- [ ] **Step 1: Write the failing check**

```lua
-- when the backend is unreachable, the UI currently only logs a warning
-- and the user sees no direct explanation
```

- [ ] **Step 2: Run the check to verify it fails**

Run: click **Create New Account** while the API backend is stopped
Expected: only a warning in logs, no visible error box

- [ ] **Step 3: Write minimal implementation**

```lua
local function showCreateAccountError(message)
    displayErrorBox(tr("Create Account Error"), tr(message or "The account creation server is not responding. Please try again later."))
end
```

- [ ] **Step 4: Run the check to verify it passes**

Run: stop the API backend and click **Create New Account**, then try **Start Playing**
Expected: a visible error box explains that the account creation server is unavailable

- [ ] **Step 5: Commit**

```bash
git add modules/client_entergame/createAccount.lua
git commit -m "fix: show create account backend errors"
```

### Task 3: Update deployment notes for the split origin

**Files:**
- Modify: `docs/deploy-vps.md:18-63`
- Test: manual docs review

- [ ] **Step 1: Write the failing check**

```text
The docs still imply the same base URL can be used for both the browser bundle and the API.
```

- [ ] **Step 2: Run the check to verify it fails**

Run: read the VPS deployment notes
Expected: no explicit `8090` vs `8088` split for browser vs API

- [ ] **Step 3: Write minimal implementation**

```md
- `8090` browser client
- `8088` account/login API
Use `TIBIAOT_WEB_BASE_URL` for the browser bundle and `TIBIAOT_API_BASE_URL` for API requests.
```

- [ ] **Step 4: Run the check to verify it passes**

Run: read the updated doc
Expected: it clearly distinguishes the two origins and the env vars

- [ ] **Step 5: Commit**

```bash
git add docs/deploy-vps.md
git commit -m "docs: split browser and api deployment notes"
```
