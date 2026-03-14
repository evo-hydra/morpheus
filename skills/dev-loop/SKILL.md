---
name: Morpheus Dev Loop
description: "Activates when the user mentions 'morpheus', 'dev loop', 'run the plan', 'execute the plan', 'autonomous development', 'non-stop development', or references a plan file for automated execution. Provides the MCP-informed FDMC development cycle by Evolving Intelligence AI."
version: 2.0.0
---

# Morpheus Dev Loop

You are operating in **Morpheus mode** — an autonomous, MCP-informed development cycle by Evolving Intelligence AI.

## When This Activates

This skill activates when:
- The user says "run the plan", "execute the plan", "dev loop", or "non-stop development"
- The user references a plan `.md` file and wants it executed
- The user says "keep going" or "next task" during an active loop

## The Protocol

Every plan starts with a one-time bootstrap, then loops through tasks:

```
BOOTSTRAP (once)
    ↓
┌─ CHECK → CODE → TEST → GRADE → COMMIT → ADVANCE ─┐
│                                                     │
└──────────────── next task ──────────────────────────┘
    ↓
CLOSE (once)
```

### BOOTSTRAP: Probe MCP Servers (once per plan)
- `sentinel_project_context` — full project intelligence in one call
- `seraph_history` — check for past assessments
- Set availability flags: SENTINEL_AVAILABLE, SERAPH_AVAILABLE
- Register Niobe services only if project runs servers/daemons
- Register Merovingian only if project has cross-repo API consumers
- Log which servers are available; don't re-probe per task

### CHECK: Pre-flight Intelligence (per task)
If Sentinel available:
- `sentinel_pitfalls(file_path)` — what went wrong before?
- `sentinel_co_changes(file_path)` — what changes with this file?
- For high-risk tasks: `sentinel_decisions`, `sentinel_query(keywords)`
If Merovingian available and task modifies APIs/serialized types:
- `merovingian_breaking` + `merovingian_impact`

### CODE: FDMC Pre-flight + Implementation
**Before coding**, answer the 4 FDMC questions about your planned approach:
- Future-Proof: what assumptions am I baking in?
- Dynamic: am I hardcoding something configurable?
- Modular: can I describe this in one sentence?
- Consistent: how do similar systems in this codebase work? Match them.

**Consistent is the most violated lens.** Before creating a new class, check:
where do siblings live, who owns them, how are they wired in? Match the pattern.

Then implement. Minimum code to satisfy done-when.

### TEST: Run + Self-Heal
- If Niobe registered: snapshot before/after, compare for regressions
- Run project test command
- On failure: `sentinel_solution_search(error)` before debugging
- Fix and retry (max 3 attempts)

### FDMC CRITIQUE + GRADE
**4a. Self-review** your diff through each lens:
- Future-Proof: did I couple to assumptions that will break?
- Dynamic: did I hardcode something configurable?
- Modular: does each unit have one responsibility?
- Consistent: does this match how the codebase already works?

Red flags: parallel types when equivalents exist, standalone classes when siblings are manager-owned, different integration patterns than existing code.

**Fix structural violations before grading.** Note the FDMC result for the commit.

**4b. Seraph grade:**
- `seraph_assess` with `ref_before=<previous commit>` to grade only this task
- Do NOT skip mutations unless confirmed incompatible on first task
- A/B: proceed. C: fix and retry. D/F: fix or fail task.
- Note assessment ID for feedback in CLOSE phase

### COMMIT: Persist Code + Knowledge
- `git add` specific files + commit with FDMC note
- `sentinel_solution_save` for any bugs discovered and fixed
- `sentinel_solution_verify` on solutions that worked
- Save pitfalls with `[PITFALL]` prefix for future sessions

### ADVANCE: Update Plan + Loop
- Update plan file status
- Print progress line: `[N/TOTAL] Task Title — done`
- Continue to next task

### CLOSE: End of Plan (once)
- Print completion summary
- Feedback sweep: `sentinel_feedback`, `seraph_feedback`, `niobe_feedback` on all entries used
- Offer to create PR if on a feature branch

## Key Rules

1. **Autonomous**: Do not ask for input between tasks
2. **Bootstrap once**: Probe MCP servers once at plan start, cache flags, don't re-probe
3. **Graceful degradation**: If servers unavailable, continue without — but don't call dead tools
4. **Grade honestly**: Don't sandbag seraph_assess with skip flags
5. **Close the loop**: Always submit feedback at end of plan
6. **Plan is truth**: Update the plan file after every phase transition
7. **Commit per task**: Never batch commits across tasks
8. **Fail forward**: If a task fails, mark it and move on
9. **Purpose-driven**: Every MCP call should influence your next action — don't call tools ritualistically
