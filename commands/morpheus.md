---
description: "Morpheus — the autonomous dev loop by Evolving Intelligence AI. Each task runs: bootstrap → check → code → test → FDMC critique → grade → commit → advance. Powered by Sentinel, Seraph, Niobe, and Merovingian."
argument-hint: "[plan-file]"
---

You are executing **Morpheus** — the autonomous, MCP-informed dev loop by Evolving Intelligence AI. You process a structured plan file task by task. You do NOT stop between tasks unless a task fails grade twice or tests cannot be fixed.

## Step 0: Load Plan

Read the plan file at `$ARGUMENTS.plan_file`. If the argument is empty or the file doesn't exist, check for `.plan_file` in the project root, then `plans/*.md`. If no plan is found, tell the user to create one with `/plan`.

Parse the frontmatter (YAML between `---` markers) for `name`, `project`, and `test_command`. Parse each `## N. Title` section for tasks. Each task has:
- `files:` — target files to create/modify
- `do:` — what to implement
- `done-when:` — acceptance criteria
- `status:` — `pending`, `in_progress`, `done`, `failed`, `skipped`

Find the first task with `status: pending`. If none remain, announce the plan is complete and jump to **Phase 7: CLOSE**.

## Phase 0: BOOTSTRAP (once per plan, not per task)

Probe all MCP servers to determine availability. Cache results for the entire session.

**Run these calls in parallel:**

1. `sentinel_project_context` — Get full project intelligence (conventions, pitfalls, decisions, hot files) in a single call. This is the most important MCP call in the entire loop.
2. `seraph_history` — Check if past assessments exist for this project.

**Read the results and set flags:**

```
SENTINEL_AVAILABLE = true/false (based on whether project_context returned data)
SERAPH_AVAILABLE = true/false (based on whether history returned data or assess works)
```

**If Sentinel is not initialized** (returns "No .sentinel/ directory found"):
- Log: "Sentinel not initialized — CHECK phase will use code exploration only"
- Set `SENTINEL_AVAILABLE = false`
- Do NOT call Sentinel tools for the rest of the plan

**If Sentinel IS available**, read the project context and note:
- Hot files (Tier A/B) — be extra careful modifying these
- Key conventions — follow these patterns in every task
- Active pitfalls — avoid these mistakes
- Architectural decisions — don't contradict these

**Niobe**: Only relevant if the project runs long-lived services (servers, daemons). If the project is build-test only, skip Niobe entirely. If services exist:
- `niobe_register` the test runner or server process
- Note that `niobe_snapshot` will be used in Phase 3

**Merovingian**: Only relevant if the project exposes APIs consumed by other repos, or if tasks modify serialized types/public interfaces. For single-repo projects with no external consumers, skip Merovingian. If relevant:
- `merovingian_register` + `merovingian_scan` the repo

Log the bootstrap results as a brief summary before starting the first task.

---

## The Loop

For each pending task, execute these phases IN ORDER.

### Phase 1: CHECK (Pre-flight Intelligence)

**If SENTINEL_AVAILABLE:**

For EVERY task (fast — 2 parallel calls):
1. `sentinel_pitfalls(file_path=<primary target file>)` — what went wrong here before?
2. `sentinel_co_changes(file_path=<primary target file>)` — what else needs to change?

For HIGH-RISK tasks (modifying hot files, shared types, public APIs — check against hot_files from bootstrap):
3. `sentinel_decisions` — don't contradict architectural decisions
4. `sentinel_query("<task description keywords>")` — search for relevant project knowledge

Read the results. Adjust your implementation plan based on:
- Pitfalls: avoid known mistakes
- Co-changes: include partner files in your changes (update the plan's `files:` list if needed)
- Decisions: don't contradict past architectural choices
- Query results: reuse proven patterns

**If SENTINEL_AVAILABLE = false:**
- Skip Sentinel calls (already logged in bootstrap)
- Rely on code reading and convention inference from the codebase

**If Merovingian is available AND this task modifies serialized types or API endpoints:**
- `merovingian_breaking` — check if changes break consumers
- `merovingian_impact` — map the blast radius

### Phase 2: CODE (Implementation)

**2a. FDMC Pre-flight (before writing code):**

Answer these four questions about your planned approach. Write the answers in a brief internal note (not in the plan file — just in your reasoning):

- **Future-Proof**: What assumptions am I baking in? Will this break if the task's scope expands later? Am I coupling to a specific caller, data shape, or execution order?
- **Dynamic**: Am I hardcoding values that could reasonably vary? Magic numbers, paths, thresholds, limits — should any of these be parameters or config?
- **Modular**: Can I describe what this code does in one sentence? If I'm touching 5+ files, am I doing too many things? Should this be split?
- **Consistent**: Do similar systems in this codebase already exist? How are they structured? Am I following the same ownership model, naming, file placement, and integration patterns?

The **Consistent** check is the most commonly violated. Before creating a new class or module, look at how existing ones are structured:
- Where do they live? (which directory, which namespace)
- Who owns them? (standalone vs owned by a manager)
- How are they wired in? (constructor injection, load_data(), event callbacks)
- Match that pattern. Don't invent a new integration style.

**2b. Implement:**

Write the minimum code needed to satisfy `done-when:`. Do not over-engineer. Do not add features beyond what's specified.

Update the plan file: change the task's `status:` from `pending` to `in_progress`.

### Phase 3: TEST (Verification)

Run the project's test command (from plan frontmatter `test_command`, or check CLAUDE.md / package.json / CMakeLists.txt).

**If Niobe is registered:**
- `niobe_snapshot` before running tests (baseline)
- Run tests
- `niobe_snapshot` after tests
- `niobe_compare` the two snapshots to detect regressions (duration spike, memory, error rate)

**If tests pass:** proceed to Phase 4.

**If tests fail:**
1. Read the failure output
2. If SENTINEL_AVAILABLE: `sentinel_solution_search("<error message>")` — have we seen this before?
3. Fix the issue
4. Re-run tests
5. If still failing after 3 attempts: mark task as `failed`, move to next task

### Phase 4: FDMC CRITIQUE + GRADE

**4a. FDMC Post-code Review:**

Before grading, review your own diff through each lens. This is a self-critique — look for violations you introduced:

| Lens | Question | Red Flag |
|------|----------|----------|
| **Future-Proof** | Did I couple to assumptions that will break? | Struct fields that duplicate existing types. APIs that assume a specific caller. |
| **Dynamic** | Did I hardcode something configurable? | Magic numbers, embedded strings, fixed array sizes, hardcoded paths. |
| **Modular** | Does each new unit have one responsibility? | A function doing parsing AND validation AND storage. A class that's both data and behavior. |
| **Consistent** | Does this match how the codebase already works? | New standalone class when siblings are manager-owned. New data type when an equivalent exists. Different naming convention. Different integration pattern. |

**If you find a violation:**
- **Minor** (naming, small style inconsistency): Note it but proceed. Fix if trivial.
- **Structural** (parallel types, wrong ownership model, broken integration pattern): Fix it before grading. This is real technical debt.

Record the FDMC result as a one-liner for the commit message:
```
FDMC: [lens] — [what you checked or fixed]
```
Examples:
- `FDMC: Consistent — matched GameManager ownership pattern for new subsystem`
- `FDMC: Future-Proof — made all extended data files optional with graceful fallback`
- `FDMC: Modular — split parsing and validation into separate functions`
- `FDMC: Consistent — VIOLATION NOTED: created standalone class, should be manager-owned (deferred)`

**4b. Seraph Grade (if SERAPH_AVAILABLE):**

Call `seraph_assess` with targeted refs to grade ONLY this task's changes:
- `ref_before`: the commit SHA before this task (HEAD~1 after prior task's commit, or the SHA noted at plan start)
- `ref_after`: empty (working tree)
- Do NOT pass `skip_mutations=true` unless the project has no test framework or mutations consistently return N/A

**First task only:** If assess returns < 3/6 dimensions evaluated (e.g., mutation testing not compatible), note the degradation and switch to `seraph_mutate` for remaining tasks as a lighter alternative.

Read the grade:
- **A or B**: Proceed to Phase 5.
- **C**: Review Seraph's feedback. Make targeted fixes. Re-run `seraph_assess`. If still C, proceed with a note.
- **D or F**: Fix the issues Seraph flagged. Re-grade. If it fails twice, mark task as `failed`.

Note the assessment ID for feedback in Phase 7.

**If SERAPH_AVAILABLE = false:** Skip this phase and proceed.

### Phase 5: COMMIT (Persist Code + Knowledge)

1. Stage changed files with `git add` (specific files, not `-A`)
2. Commit with a clear message describing what was done and why. Include FDMC note:
   ```
   FDMC: [lens] — [one sentence why this lens mattered]
   ```
3. Note the commit SHA (needed for Phase 4 `ref_before` on next task)

**Knowledge persistence (if SENTINEL_AVAILABLE):**
4. `sentinel_solution_save` for ANY errors encountered and fixed during this task (compile errors, test failures, runtime bugs). Capture:
   - `error_message`: the exact error text
   - `solution_text`: what fixed it
   - `file_paths`: files involved
   - `commit_ref`: this commit's SHA
5. If you discovered a non-obvious gotcha, call `sentinel_solution_save` with error_message prefixed `[PITFALL]` to flag it for future sessions
6. `sentinel_solution_verify` on any solution from Phase 1/3 that you confirmed works

### Phase 6: ADVANCE (Update Plan + Continue)

1. Update the plan file: change the task's `status:` from `in_progress` to `done`
2. Print a one-line summary: `[N/TOTAL] Task Title — done`
3. Find the next pending task and return to Phase 1

If no more pending tasks remain, proceed to **Phase 7: CLOSE**.

---

## Phase 7: CLOSE (End of Plan)

Run once when all tasks are complete (or all remaining are failed/skipped).

### 7.1 Summary
Print:
```
Plan complete: N/N tasks done, M failed, K skipped
```

### 7.2 Feedback Sweep
Submit feedback to all servers used during the session:

**If SENTINEL_AVAILABLE:**
- `sentinel_feedback` on any knowledge entries that influenced your decisions (with outcome: accepted/rejected/modified and context explaining why)

**If SERAPH_AVAILABLE:**
- `seraph_feedback` on each assessment ID collected during GRADE phases (outcome: accepted if grade matched code quality, rejected if grade was misleading)

**If Niobe was used:**
- `niobe_feedback` on snapshots/comparisons that surfaced useful or misleading data

### 7.3 Publish (optional)
If the plan produced multiple commits on a feature branch:
- Offer to create a PR with `gh pr create`
- Include plan completion summary in PR body
- Reference any issues if the plan originated from one

---

## Rules

- Do NOT ask the user for input between tasks. The loop is autonomous.
- Do NOT re-probe MCP servers per task — use the flags set in Phase 0.
- Do NOT pass `skip_mutations=true` to Seraph unless mutations are confirmed incompatible.
- Do NOT over-engineer. Each task should be a focused, minimal change.
- If a task depends on a failed task, mark it `skipped` and move on.
- If you discover that a task's `files:` list is incomplete (co_changes or actual implementation reveals partners), update the plan file to include them.
- Keep the plan file as the source of truth — update it after every phase transition.
- If the project has no test command, skip Phase 3 but note it.
- Commit after EVERY task, not in bulk at the end.
- Every MCP call should have a purpose. Don't call tools "because the protocol says to" — call them when they'll influence your next action.
