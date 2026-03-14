# Morpheus

**"I'm trying to free your mind, Neo."**

The autonomous dev loop for [Claude Code](https://claude.ai/code). Connects AI agents to project intelligence, runtime observation, contract verification, and mutation testing in a single FDMC-informed development cycle.

By [Evolving Intelligence AI](https://evolvingintelligence.ai)

---

## What It Does

Morpheus is a Claude Code plugin that turns a structured plan into committed code — autonomously. For each task in your plan, it runs:

```
BOOTSTRAP (once)     Probe MCP servers, load project intelligence
    |
    v
  CHECK              Sentinel: pitfalls, co-changes, conventions
  CODE               FDMC pre-flight, then implement
  TEST               Run tests, self-heal on failure
  FDMC CRITIQUE      Self-review diff for structural violations
  GRADE              Seraph: mutation testing + quality gate
  COMMIT             Git commit + persist knowledge to Sentinel
  ADVANCE            Update plan, next task
    |
    v
CLOSE (once)         Feedback sweep to all MCP servers
```

It does not stop between tasks. It does not ask for permission. It checks project intelligence before coding, critiques its own work after coding, and saves what it learns for next time.

## What Makes It Different

| Capability | Aider | Cline | Kiro | Morpheus |
|-----------|-------|-------|------|----------|
| Pre-flight project intelligence | - | - | - | Sentinel |
| Mutation testing quality gate | - | - | - | Seraph |
| Runtime observation | - | - | - | Niobe |
| API contract verification | - | - | - | Merovingian |
| Structured self-critique (FDMC) | - | Verify step | - | Pre + post code |
| Cross-session knowledge persistence | - | - | - | solution_save |
| Feedback loop closure | - | - | - | *_feedback tools |

## Install

**One command:**

```bash
git clone https://github.com/evo-hydra/morpheus ~/.claude/plugins/morpheus
```

**Or via script:**

```bash
curl -sSL https://raw.githubusercontent.com/evo-hydra/morpheus/main/install.sh | bash
```

That's it. Open Claude Code and `/morpheus` is available.

## Quick Start

### 1. Create a plan

```
/plan "Add user authentication with JWT tokens and refresh flow"
```

Morpheus generates a structured plan file at `plans/add-auth.md` with ordered tasks, target files, and acceptance criteria.

### 2. Run the loop

```
/morpheus plans/add-auth.md
```

Morpheus executes every task autonomously: check intelligence, write code, run tests, self-critique, grade, commit, advance. You watch. It ships.

### 3. (Optional) Install MCP servers for full intelligence

Morpheus works without any MCP servers — it degrades gracefully. But with them, it sees:

```bash
pip install git-sentinel    # Project history: conventions, pitfalls, co-changes
pip install seraph-ai       # Quality gate: mutation testing, static analysis
pip install niobe            # Runtime: process metrics, log analysis, anomalies
pip install merovingian      # Contracts: API breaking changes, consumer mapping
```

Each server adds a layer of intelligence. Sentinel is the highest-value single install.

## The FDMC Quality Standard

Every task runs through four lenses — before and after coding:

- **Future-Proof** — Am I coupling to assumptions that will break?
- **Dynamic** — Am I hardcoding something that should be configurable?
- **Modular** — Does each unit have one clear responsibility?
- **Consistent** — Does this match how the codebase already works?

**Consistent is the most violated lens.** Before creating a new class, Morpheus checks: where do siblings live? Who owns them? How are they wired in? Match the pattern.

Structural violations (parallel types, wrong ownership model) are fixed before grading. The FDMC result is recorded in every commit message.

## The MCP Intelligence Layer

Morpheus orchestrates five MCP servers from the [EvoIntel suite](https://github.com/evo-hydra):

| Server | What It Sees | Install |
|--------|-------------|---------|
| **Sentinel** | Conventions, pitfalls, decisions, hot files, co-changes, solution memory | `pip install git-sentinel` |
| **Seraph** | Mutation survival, static analysis, flakiness, risk scoring | `pip install seraph-ai` |
| **Niobe** | Process metrics, log patterns, error rates, anomalies | `pip install niobe` |
| **Merovingian** | API contracts, consumer relationships, breaking changes | `pip install merovingian` |
| **Anno** | Clean text from any URL (93% token reduction) | `npm install -g @evointel/anno` |

All are open source. All use SQLite + WAL + FTS5. No cloud. No Docker.

## How the Loop Uses Them

### Phase 0: BOOTSTRAP
```
sentinel_project_context  →  Load conventions, pitfalls, decisions, hot files
seraph_history            →  Check for past assessments
```

### Phase 1: CHECK (per task)
```
sentinel_pitfalls(file)   →  What went wrong in this file before?
sentinel_co_changes(file) →  What else needs to change with it?
merovingian_breaking      →  Will this change break consumers?
```

### Phase 3: TEST
```
niobe_snapshot (before)   →  Capture baseline metrics
run tests
niobe_snapshot (after)    →  Capture post-change metrics
niobe_compare             →  Detect regressions
```

### Phase 4: GRADE
```
seraph_assess             →  Mutation testing + static analysis + risk scoring
```

### Phase 5: COMMIT
```
sentinel_solution_save    →  Persist any bugs discovered and their fixes
sentinel_solution_verify  →  Mark confirmed solutions
```

### Phase 7: CLOSE
```
sentinel_feedback         →  Rate the knowledge that was used
seraph_feedback           →  Rate the assessment quality
```

## Plan File Format

```markdown
---
name: Add Authentication
project: /path/to/project
created: 2026-03-14
test_command: "npm test"
---

## 1. Create JWT Token Service
- **files**: src/auth/jwt.ts, src/auth/types.ts
- **do**: Implement JWT generation and verification with RS256
- **done-when**: Unit tests pass for token creation, validation, and expiry
- **status**: pending

## 2. Add Login Endpoint
- **files**: src/routes/auth.ts, src/middleware/auth.ts
- **do**: POST /auth/login returns access + refresh tokens
- **done-when**: Integration test passes with valid and invalid credentials
- **status**: pending
```

## Commands

| Command | Description |
|---------|-------------|
| `/morpheus [plan-file]` | Execute the autonomous dev loop |
| `/plan [description]` | Create a structured plan from a description |
| `/plan [file-path]` | View plan status |

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Git (for commits)
- A project with tests (for Phase 3)

MCP servers are optional but recommended. Morpheus works without them — it just can't see as much.

## The Five Blindnesses

Morpheus exists because AI coding agents are blind to five things no model improvement will fix:

1. **Project history** — Conventions, pitfalls, and decisions locked in git
2. **Runtime behavior** — CPU, memory, errors that require process observation
3. **Cross-service dependencies** — API contracts that span repositories
4. **Code quality beyond "tests pass"** — Mutations that survive mean tests verify nothing
5. **Web content** — 93% of HTML tokens are noise

Each MCP server in the EvoIntel suite gives the agent sight into one blindness. Morpheus is the brain that connects them into a coherent development cycle.

Read the full thesis: [AI Coding Agents Are Blind](docs/whitepaper.md)

## License

MIT

## Credits

Built by [Evolving Intelligence AI](https://evolvingintelligence.ai) | [GitHub](https://github.com/evo-hydra)

Matrix naming: Morpheus guides Neo through the Matrix using intelligence from Sentinel, Niobe, Seraph, and Merovingian.
