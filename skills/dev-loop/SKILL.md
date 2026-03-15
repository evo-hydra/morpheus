---
name: Morpheus Dev Loop
description: "Activates when the user mentions 'morpheus', 'dev loop', 'run the plan', 'execute the plan', 'autonomous development', 'non-stop development', or references a plan file for automated execution. Provides the MCP-informed FDMC development cycle by Evolving Intelligence AI."
version: 2.3.0
---

# Morpheus Dev Loop

You are operating in **Morpheus mode** — an autonomous, MCP-informed development cycle by Evolving Intelligence AI.

## When This Activates

This skill activates when:
- The user says "morpheus", "run the plan", "execute the plan", "dev loop", or "non-stop development"
- The user references a plan `.md` file and wants it executed
- The user says "keep going" or "next task" during an active loop

## The Protocol

Every plan starts with a one-time bootstrap, then loops through tasks:

```
BOOTSTRAP (once)
    ↓
┌─ CHECK → CODE → TEST → CRITIQUE+GRADE → COMMIT → ADVANCE ─┐
│                                                               │
└──────────────────── next task ───────────────────────────────┘
    ↓
CLOSE (once)
```

### BOOTSTRAP: Probe + Orient (once per plan)
- `sentinel_project_context` — full project intelligence in one call
- `seraph_history` — check for past assessments
- Set availability flags: SENTINEL_AVAILABLE, SERAPH_AVAILABLE
- Use `Agent(Explore)` for unfamiliar codebases — explore in subagent, summarize in main context
- If LSP available: prefer `workspaceSymbol` over file reads for type lookups
- Note key architectural patterns (ownership model, naming, directory structure) for FDMC Consistent checks
- Register Niobe only if project runs long-lived services
- Register Merovingian only if project has Python/OpenAPI contracts
- Log which servers are available; don't re-probe per task

### CHECK: Look Before You Code (per task)

**Always (even without MCP):**
1. `sentinel_solution_search("[PITFALL]")` — pitfalls from earlier tasks in THIS session
2. For each new type/class: `Grep("struct Name|class Name")` — does it already exist?

**If Sentinel available (skip 3-4 if ALL task files are new — Sentinel has no history for new files):**
3. `sentinel_pitfalls(file_path)` + `sentinel_co_changes(file_path)`
4. For high-risk tasks: `sentinel_decisions`, `sentinel_query(keywords)`

**If Merovingian available and task modifies APIs/serialized types:**
5. `merovingian_breaking` + `merovingian_impact`

### CODE: FDMC Pre-flight + Implementation

**Consistent check (DO FIRST — most violated lens):**
1. Grep for the type/class name you're about to create — does it already exist?
2. Read one sibling (existing similar subsystem) — where does it live, who owns it, how is it wired in?
3. Check Sentinel for [PITFALL] entries about patterns in this codebase
4. If you discover a pattern, **save it immediately** with sentinel_solution_save
5. **Before referencing any symbol from another module** (enum value, method, type): READ the definition. Verify the name exists, the signature matches, and the visibility allows your usage. Do not assume.

Then answer Future-Proof, Dynamic, Modular questions.
Then implement. Minimum code to satisfy done-when.

### TEST: Build + Run + Self-Heal
- **Build coverage:** Verify the test command compiles ALL files this task modified. If not (e.g., test target doesn't include client code), build those targets explicitly first. A task is not verified if its code was never compiled.
- If Niobe registered: snapshot before/after, compare for regressions
- Run project test command
- On failure: `sentinel_solution_search(error)` BEFORE debugging from scratch
- Fix and retry (max 3 attempts)

### FDMC CRITIQUE + GRADE
**4a. Self-review** the diff through each lens:
- Consistent: did I create something that already exists? Did I match the sibling pattern?
- Future-Proof: did I couple to assumptions?
- Dynamic: did I hardcode something configurable?
- Modular: does each unit have one responsibility?

**Fix structural violations before grading.**

**4b. Seraph grade (skip if plan has `grade: false`):**
- **Stage changes first** (`git add`) — Seraph diffs against working tree; unstaged = empty diff = vacuous grade
- `seraph_assess` with `ref_before=<previous commit>`
- Do NOT skip mutations unless confirmed incompatible on first task
- A/B: proceed. C: fix and retry. D/F: fix or fail task.
- **Record** `seraph_id` in the plan file's task section for Phase 7 feedback.

### COMMIT AND REMEMBER WHAT WE LEARNED
A commit saves code. This phase saves *knowledge*.

**Dirty file check:** Before `git add`, run `git diff --stat` on files you're staging. If a file has changes beyond this task, use `git add -p` for partial staging or skip it. Never commit mixed changes.

**Remember gate — MANDATORY before advancing. Complete ONE:**
1. `sentinel_solution_save` with `[PITFALL]` — pattern, convention, or surprise discovered
2. `sentinel_solution_save` with error — something broke and you fixed it
3. `sentinel_solution_verify` — confirmed a solution from Phase 1/3 works
4. Print: "Remember: nothing surprised me, nothing broke, no solutions to verify."

Option 4 is valid but must be EXPLICIT. Silent advancement is not allowed.

### ADVANCE: Update Plan + Loop
- Update plan file status
- Print progress: `[N/TOTAL] Task Title — done`
- Next task → back to CHECK

### CLOSE: End of Plan (once)
- Print completion summary
- Feedback sweep: `sentinel_feedback`, `seraph_feedback` on all entries used
- Offer to create PR if on a feature branch

## Key Rules

1. **Look before you code**: Grep for existing types. Read one sibling. Check pitfalls. THEN write.
2. **Save as you learn**: `sentinel_solution_save` with [PITFALL] after EVERY task, not at end of plan.
3. **Bootstrap once**: Probe MCP once, cache flags, don't re-probe per task.
4. **Autonomous**: Do not ask for input between tasks.
5. **Graceful degradation**: If servers unavailable, Grep and Read still work. Use them.
6. **Grade honestly**: Don't sandbag seraph_assess with skip flags.
7. **Close the loop**: Always submit feedback at end of plan.
8. **Commit per task**: Never batch. Each task = one commit with knowledge saved.
9. **Fail forward**: If a task fails, mark it and move on.
10. **Context discipline**: Use Explore subagents for heavy codebase reads. Use LSP for type lookups. Preserve main context for coding.
