# EvoIntel: Verification Infrastructure for AI-Native Development

**The Five Blindnesses Framework, the Dev Loop Protocol, and the MCP Suite**

Version 2.0 | March 14, 2026 | Evolving Intelligence AI

---

## Executive Summary

AI coding agents are not limited by intelligence. They are limited by blindness — structural inability to perceive project history, runtime behavior, cross-service dependencies, code quality beyond test passage, and web content buried in HTML noise. No model improvement fixes this. The gap between what AI can think and what it can see is growing, not shrinking.

EvoIntel addresses this with three layers:

1. **The MCP Suite** — Five local sidecar tools (Sentinel, Niobe, Merovingian, Seraph, Anno) that give AI agents sight into what they structurally cannot reach. 35 MCP interfaces. 648 tests. SQLite + WAL + FTS5. No cloud. No Docker.

2. **FDMC** — A four-lens quality standard (Future-Proof, Dynamic, Modular, Consistent) that encodes the judgment models lack. Applied as a pre-code checkpoint and post-code self-critique.

3. **The Dev Loop** — An autonomous development protocol that orchestrates the suite into a coherent cycle: bootstrap MCP servers once, then for each task: check intelligence, code with FDMC, test, self-critique, grade with mutation testing, commit with knowledge persistence, advance. Closes the feedback loop at end of plan.

Together, these form the first complete verification infrastructure for AI-assisted development — from project understanding through implementation through quality gate through knowledge persistence.

---

## Part I: The Problem

### The Five Blindnesses

AI coding agents face five structural gaps that no model improvement will fix:

**1. Project History** — AI can read files. It cannot read institutional memory. Why was that workaround added? Which files always break together? What conventions are actually followed? What approaches were tried and reverted? This intelligence lives in thousands of commits, PR descriptions, and co-change patterns — outside any context window.

**2. Runtime Behavior** — AI can reason about what code should do. It cannot observe what it actually does. CPU spikes, memory leaks, error rates, log anomalies — these require process observation, not code reading. "Happened to look" is not a strategy.

**3. Cross-Service Dependencies** — Change an API field in one service and you silently break downstream consumers. No local test catches it. No linter flags it. The blast radius extends beyond the AI's field of vision.

**4. Code Quality Beyond "Tests Pass"** — AI-generated tests can achieve 100% line coverage while scoring only 4% on mutation testing. They assert that code runs without errors, not that it produces correct results. "All tests pass" is a necessary condition, not a sufficient one.

**5. Web Content** — AI agents fetch documentation as raw HTML. ~93% of tokens are navigation, ads, scripts, and chrome. You pay the full cost in context window consumption and degraded attention. The HTML needs to be removed, not better understood.

### The Numbers

These blindnesses are not theoretical:

- **Veracode (2025)**: 45% of AI-generated code contained CWE vulnerabilities
- **Georgetown CSET**: 68-73% of Copilot/InCoder samples had manually verified vulnerabilities
- **CrowdStrike**: 19% baseline vulnerability rate, jumping to 27.2% with bias triggers
- **GitClear (2025)**: Copy-pasted code rose from 8.3% to 12.3%; refactoring collapsed from 25% to under 10%
- **Qodo (2025)**: Only 3.8% of developers report both low hallucinations AND high confidence shipping AI code
- **Mutation testing research**: AI tests achieve 100% line coverage but only 4% mutation scores

Model improvement addresses reasoning. Blindness requires infrastructure.

---

## Part II: The MCP Suite

### Architecture: Local Sidecar Intelligence

Every tool follows the same pattern:

1. Identify what the AI literally cannot see
2. Build a local sidecar that extracts intelligence from that domain
3. Persist it locally — SQLite, WAL mode, FTS5 search. Single file. No cloud, no Docker
4. Expose it via MCP so the agent can query it like any other tool

The AI doesn't get smarter. It gets informed.

### Shared Engineering DNA

| Layer | Implementation |
|-------|---------------|
| Storage | SQLite + WAL + FTS5. Database at `.tool-name/tool-name.db` |
| Transport | FastMCP over stdio (except Anno: HTTP) |
| Config | `.tool-name/config.toml` → env vars → frozen dataclass defaults |
| CLI | Typer + Rich on stderr (MCP-safe) |
| Output | Markdown, paginated, capped ~4,000 tokens |
| Build | Hatchling, `src/` layout, optional MCP extra |

### The Five Tools

| Blindness | Tool | Version | Tests | MCP Tools | What It Sees |
|-----------|------|---------|-------|-----------|-------------|
| Project history | **Sentinel** | 0.4.0 | 329 | 11 | Conventions, pitfalls, decisions, hot files, co-changes, solution memory |
| Runtime behavior | **Niobe** | 0.2.0 | 14 | 8 | Process metrics, log patterns, error rates, anomalies |
| Cross-service deps | **Merovingian** | 0.1.0 | 187 | 8 | API contracts, consumer relationships, breaking changes |
| Code quality | **Seraph** | 0.1.0 | 17 | 4 | Mutation survival, static analysis, flakiness, risk scoring |
| Web content | **Anno** | 1.0.1 | 101 | 4 | Clean text from any URL via 5-extractor ensemble |

**Total: 5 servers. 35 MCP interfaces. 648 tests. Open source.**

### Sentinel: Institutional Memory

Extracts from git history: **conventions** (patterns with confidence scores), **pitfalls** (mistakes from reverts/bug fixes with severity), **decisions** (architectural choices with rationale), **hot files** (churn x fragility risk tiers), **co-changes** (file pairs that historically change together), **solution memory** (error fingerprints linked to fixes, searchable via FTS5).

The feedback loop is critical: agents submit accepted/rejected/modified on knowledge entries, recalibrating confidence scores. Over time, Sentinel learns which conventions are actually followed.

### Niobe: Runtime Observation

Snapshot-based, not continuous. Register a service → snapshot (capture metrics via psutil, ingest logs) → make change → snapshot again → compare. Anomaly detection after 3+ baselines flags metrics exceeding mean + 2 sigma.

### Merovingian: Contract Intelligence

Scans OpenAPI specs and Pydantic models. Direction-aware breaking change detection (same change has opposite semantics in request vs response). Consumer registry creates dependency graph. Impact analysis maps blast radius across repos.

### Seraph: Verification Beyond Tests

7-step pipeline: diff → baseline (flaky detection) → mutation testing (mutmut) → static analysis (ruff + mypy) → Sentinel risk signals → scoring → persistence. Five-dimension grade: mutation score (30%), static cleanliness (20%), test baseline (15%), Sentinel risk (20%), co-change coverage (15%).

### Anno: Clean Signal from Web Noise

Five extractors in parallel (Readability, DOM heuristic, Trafilatura, domain-specific, Ollama LLM). Confidence scoring selects best result. Average 92.7% token reduction. 14 web pages in the space raw HTML uses for one.

---

## Part III: FDMC — The Quality Standard

### The Four Lenses

FDMC encodes the judgment that models lack. Before and after every code change:

- **Future-Proof** — Will this break when requirements change? Avoid tight coupling to current assumptions. Am I baking in assumptions about callers, data shapes, or execution order?

- **Dynamic** — Am I hardcoding something that should be configurable? Prefer parameters over literals. Magic numbers, paths, thresholds, limits — should these be config?

- **Modular** — Does this have one clear responsibility? If you can't describe it in one sentence, split it. If you're touching 5+ files, you're doing too many things.

- **Consistent** — Does this follow existing patterns in the codebase? Match what's already there before inventing something new. **This is the most commonly violated lens.**

### FDMC Anti-Patterns

- God objects or classes doing too many things
- Hardcoded secrets or environment-specific values
- Catching broad exceptions silently
- Copy-pasting instead of extracting shared logic
- Adding abstractions for things that only happen once
- Writing code for hypothetical future requirements
- Creating parallel types when equivalents exist
- Standalone classes when siblings are manager-owned
- Different integration patterns than existing code

### FDMC as a Checkpoint (Not Just a Preamble)

FDMC v1 was "read these bullet points before coding." It was ignored.

FDMC v2 operates at two checkpoints:

**Pre-code (Phase 2a)**: Answer the four questions about your planned approach. The Consistent check requires examining how sibling systems are structured — where they live, who owns them, how they're wired in.

**Post-code (Phase 4a)**: Self-review the diff through each lens. Concrete red flags:

| Lens | Red Flag |
|------|----------|
| Future-Proof | Struct fields that duplicate existing types. APIs that assume a specific caller. |
| Dynamic | Magic numbers, embedded strings, hardcoded paths. |
| Modular | Function doing parsing AND validation AND storage. |
| Consistent | New standalone class when siblings are manager-owned. New data type when equivalent exists. Different integration pattern. |

Structural violations must be fixed before grading. The FDMC result is recorded in the commit message, creating an audit trail.

---

## Part IV: The Dev Loop Protocol

### The Missing Layer

The MCP tools are sensors. FDMC is the quality standard. But neither tells the agent *when* to look, *what* to look at, or *how* to respond to what it finds.

The Dev Loop is the orchestration protocol that connects them.

### Protocol Overview

```
BOOTSTRAP (once per plan)
    |
    v
+-- CHECK --> CODE --> TEST --> FDMC CRITIQUE --> GRADE --> COMMIT --> ADVANCE --+
|                                                                                |
+-------------------------------- next task ------------------------------------+
    |
    v
CLOSE (once per plan)
```

### Phase 0: BOOTSTRAP (once)

Probe all MCP servers. Cache availability flags. Don't re-probe per task.

```
sentinel_project_context  --> SENTINEL_AVAILABLE = true/false
seraph_history            --> SERAPH_AVAILABLE = true/false
niobe (if services exist) --> register test runner / server
merovingian (if APIs)     --> register + scan repo
```

This single call to `sentinel_project_context` replaces what v1 did with 4 separate calls per task, all of which failed silently and were never retried intelligently.

### Phase 1: CHECK (per task)

If Sentinel available:
- `sentinel_pitfalls(file_path)` — what went wrong here before?
- `sentinel_co_changes(file_path)` — what else needs to change?
- For high-risk tasks: `sentinel_decisions`, `sentinel_query(keywords)`

If Merovingian available and task modifies APIs/serialized types:
- `merovingian_breaking` + `merovingian_impact`

### Phase 2: CODE (FDMC pre-flight + implementation)

FDMC pre-flight: answer the four questions. Check how siblings are structured. Then implement minimum code to satisfy acceptance criteria.

### Phase 3: TEST

Run test command. If Niobe registered: snapshot before/after, compare for regressions. On failure: `sentinel_solution_search` before debugging from scratch. Max 3 retries.

### Phase 4: FDMC CRITIQUE + GRADE

**4a.** Self-review diff through each lens. Fix structural violations (parallel types, wrong ownership model). Note the FDMC result.

**4b.** `seraph_assess` with `ref_before=<previous commit>` to grade only this task. Do NOT skip mutations. A/B: proceed. C: fix. D/F: fail task.

### Phase 5: COMMIT + KNOWLEDGE

Git commit with FDMC note. If Sentinel available: `sentinel_solution_save` for any bugs fixed, `sentinel_solution_verify` on solutions used, `[PITFALL]` prefix for non-obvious gotchas.

### Phase 6: ADVANCE

Update plan status. Print progress. Next task.

### Phase 7: CLOSE (once)

Feedback sweep: `sentinel_feedback`, `seraph_feedback`, `niobe_feedback` on all entries used. This closes the learning loop — every server gets smarter for the next session. Optionally create a PR.

### Why This Matters

The Dev Loop is the first autonomous development protocol that integrates project intelligence (Sentinel), quality verification (Seraph), runtime observation (Niobe), and dependency analysis (Merovingian) into a single coherent cycle with FDMC self-critique and feedback loop closure.

No other tool or framework does all of this:

| Capability | Aider | Cline | Kiro | SWE-Agent | Dev Loop |
|-----------|-------|-------|------|-----------|----------|
| Lint-test-fix loop | Yes | Yes | Hooks | No | Yes |
| Plan-first workflow | No | Yes | Yes (specs) | No | Yes |
| Pre-flight intelligence | No | No | No | No | **Yes (Sentinel)** |
| Mutation testing gate | No | No | No | No | **Yes (Seraph)** |
| Runtime observation | No | No | No | No | **Yes (Niobe)** |
| Contract verification | No | No | No | No | **Yes (Merovingian)** |
| Self-critique protocol | No | Verify step | No | No | **Yes (FDMC)** |
| Feedback loop closure | No | No | No | No | **Yes (*_feedback)** |
| Knowledge persistence | No | Logs | No | No | **Yes (solution_save)** |

---

## Part V: Empirical Evidence

### Case Study: hex-engine (March 14, 2026)

The Dev Loop v1 was first run against hex-engine, a C++ strategy game engine with 25+ test suites, 70+ source files, and Raylib graphical client.

**Plan**: 12 tasks from a launch plan document. Data loading, spectator UI, narrator, safety metrics, anomaly detection, camera AI, trace export, arena modes.

**Results**: 12/12 tasks completed. 11 commits. 415 tests passing. ~4,800 lines of code added across 20+ files.

### What Went Wrong (v1 Failures)

| Failure | Impact |
|---------|--------|
| Called 4 Sentinel tools per task; all returned "not initialized" | 48 wasted MCP calls, zero intelligence gathered |
| Called `seraph_assess` once with `skip_mutations=true` | Grade was 3/6 dimensions, A by default — meaningless |
| Never called `sentinel_project_context` (the single most important call) | Missed the one-shot context load |
| Never called `sentinel_solution_save` after fixing a compile error | Lost knowledge that should have been persisted |
| Never submitted feedback to any server | Broke the learning loop |
| Never used Niobe or Merovingian | Missed runtime and contract intelligence |
| Used 4 of 32 available MCP tools | 87.5% of available intelligence unused |

### FDMC Violations Detected in Self-Critique

| Task | Violation | Lens |
|------|-----------|------|
| Task 1 | Created `hex::ArtifactData` when `hex::game::ArtifactData` already existed in progression.h | **Consistent** |
| Task 2 | Had to write conversion functions between parallel types | Consequence of Task 1 violation |
| Task 7 | `SafetyMetricsTracker` is standalone — every other subsystem is owned by `GameManager` | **Consistent** |
| Task 10 | `AnomalyDetector` is standalone — same pattern violation | **Consistent** |
| Task 3 | All UI functions inline in a header — will bloat compile times | **Modular** (minor) |

### v1 → v2 Changes

These failures directly informed the v2 protocol:

- **Phase 0 BOOTSTRAP**: Probe once, cache flags, never re-probe
- **`sentinel_project_context`**: Single call, full intelligence
- **Seraph**: Use `ref_before`/`ref_after` per commit, don't skip mutations
- **FDMC Critique**: Concrete self-review with red flag table, fix structural violations before grading
- **Phase 7 CLOSE**: Feedback sweep across all servers
- **Purpose-driven calls**: "Every MCP call should influence your next action — don't call tools ritualistically"

---

## Part VI: Competitive Landscape

### The Spectrum

```
Vibe Coding -----> IDE Assistants -----> Agent Frameworks -----> Dev Loop v2
(no structure)    (rules + lint)        (ReAct loops)           (MCP intelligence +
                                                                 FDMC critique +
                                                                 mutation grading +
                                                                 feedback closure)
```

### Key Players

**Aider** — Closest to a real dev loop. Auto-lint, auto-test, auto-commit after every edit. No pre-flight intelligence, no mutation testing, no self-critique.

**Cline** — Plan-Act-Verify with full audit trail. Human approval required per action. No MCP intelligence, no mutation testing.

**Kiro (AWS)** — Spec-driven development: user stories → technical design → tasks. Most structured pre-flight. No runtime observation, no feedback loops.

**Open SWE (LangChain)** — Multi-agent with Planner + Reviewer. Closest to FDMC critique via separate reviewer. No project intelligence.

**Anthropic's own guidance** — Writer/Reviewer pattern (two separate sessions). Recommends hooks for deterministic quality gates. Emphasizes "give Claude a way to verify its own work."

### What We Do That Nobody Else Does

1. **MCP-powered project intelligence as pre-flight** — Zero public MCP servers provide convention/pitfall/co-change intelligence to coding agents
2. **Mutation testing as quality gate** — No other autonomous agent protocol runs mutations
3. **FDMC self-critique with concrete red flags** — More structured than any single-agent self-review
4. **Feedback loop closure** — Agents learn across sessions via `*_feedback` tools
5. **Knowledge persistence** — Error fingerprints linked to fixes, searchable across sessions

### What Others Do Better

1. **Separate reviewer agent** (Anthropic, Open SWE) — Self-critique has inherent bias; a fresh context catches more
2. **Spec-first** (Kiro) — We skip the spec layer; complex features benefit from data model + API surface design before task decomposition
3. **Tighter edit-lint-test** (Aider) — Lint and test after every edit, not just at end of task
4. **Granular audit trail** (Cline) — We log at plan/commit level, not individual tool calls

### Industry Trends

- **MCP is now an industry standard** — Donated to the Agentic AI Foundation (Linux Foundation), co-governed by Anthropic, OpenAI, and Block. 97M+ monthly SDK downloads.
- **AGENTS.md** — Open spec for AI agent instructions, adopted by 20,000+ GitHub repos.
- **"Vibe coding" is dying** — Coined by Karpathy (Feb 2025), declared "passe" by early 2026. Replaced by "agentic engineering."
- **Multi-agent is the direction** — Writer/Reviewer, Planner/Executor, Architect/Programmer patterns emerging everywhere.
- **Commit frequency 4x** — Gene Kim's "Three Developer Loops" recommends committing every few minutes with agents.

---

## Part VII: Gap Analysis

### Gap A: Single-Agent Self-Review

FDMC critique is the agent reviewing its own work. It has inherent sunk-cost bias. The strongest pattern in the industry is a separate reviewer with fresh context.

**Resolution**: Add a `/review` subagent to the dev loop that runs after FDMC critique with a clean context window. Or run FDMC critique via a subagent with `isolation: "worktree"`.

### Gap B: No Unified Verdict Surface

Each sidecar is strong in isolation. No single endpoint returns a combined pre-merge risk verdict across quality, contracts, history, and runtime.

**Resolution**: Build **Oracle** — a thin orchestration layer that queries all four sidecars and returns a single verdict. Named after the Matrix character who aggregates signals.

### Gap C: No Security Scoring in Seraph

Seraph runs ruff + mypy (style/type), not security static analysis. Cannot detect injection, XSS, hardcoded credentials, or crypto misuse.

**Resolution**: Integrate Bandit (Python) and Semgrep (multi-language) into Seraph's pipeline. Add CWE-specific scoring as a 6th dimension at 20% weight. 2-3 days of work.

### Gap D: Merovingian Phase-2 Intelligence

Contract drift detection (spec vs observed runtime) and cross-repo co-change prediction are not yet implemented.

### Gap E: Agent Authentication

AI agents cannot authenticate to platforms they need to act on. Scoped tokens, encrypted vaults, auditable access logs for agent identity — none of this exists.

### Gap F: Dev Loop Spec-First Layer

Complex features would benefit from a spec document (data model, API surface, integration points) before task decomposition. Currently the plan goes directly from description to tasks.

---

## Part VIII: Roadmap

### Now: Polish the Dev Loop (Q1 2026)

1. Run Dev Loop v2 against 3+ real projects to validate the protocol changes
2. Initialize Sentinel on all active projects (`sentinel init`)
3. Enable full Seraph grading (with mutations) and calibrate grade thresholds
4. Add `/review` subagent for separate-context FDMC critique
5. Add lint-on-edit hook for tighter feedback (Aider-style)
6. Publish dev-loop plugin to Claude Code plugin marketplace

### Next: Oracle + Security (Q2 2026)

1. Build Oracle MVP — thin orchestrator that queries Sentinel + Seraph + Merovingian + Niobe and returns a unified verdict
2. Integrate Bandit/Semgrep into Seraph for security scoring
3. Add Snyk Studio MCP for enterprise-grade SCA/SBOM
4. Publish the Five Blindnesses article + launch content sequence
5. Spec-first layer in `/plan` command for complex features

### Later: Calibration + Enterprise (Q3-Q4 2026)

1. Closed-loop calibration: map predicted risk (Seraph grade) to observed outcomes (Niobe runtime signals post-deploy)
2. Weight tuning: adjust verdict scoring by empirical false positives/negatives
3. Policy gates: block merge if critical security findings > 0, if breaking consumer impact unresolved, if runtime regression above threshold
4. Compliance exports: PCI DSS 6.2.3, SOC 2, SSDF evidence formatting
5. Signed audit trail across all tools

### Horizon: Multi-Agent + Platform (2027)

1. Dedicated reviewer agent with fresh context (replacing self-critique)
2. Agent authentication infrastructure (scoped tokens, encrypted vaults)
3. Contract drift detection (Merovingian + Niobe)
4. Cross-repo co-change prediction (Merovingian + Sentinel)
5. SaaS offering for teams (hosted Oracle + dashboard)

---

## Part IX: Natural Language Interface

Users don't need to remember tool names. These shortcuts map to MCP calls:

| Phrase | What Happens |
|--------|-------------|
| "Catch me up" | `sentinel_project_context` + `niobe_errors` + `git log` |
| "Check before you start" | `sentinel_pitfalls` + `sentinel_co_changes` + `sentinel_query` |
| "Have we seen this before?" | `sentinel_solution_search` + `niobe_errors` |
| "Who uses this?" | `merovingian_consumers` + `merovingian_impact` |
| "Grade what we just did" | `seraph_assess` on the diff |
| "Is the server healthy?" | `niobe_snapshot` + `niobe_errors` + `niobe_anomalies` |
| "Commit and remember" | git commit + `sentinel_solution_save` + `sentinel_solution_verify` |
| "Save that as a pitfall" | `sentinel_solution_save` with `[PITFALL]` prefix |
| "Compare before and after" | `niobe_snapshot` x2 + `niobe_compare` |
| "Check the contracts" | `merovingian_scan` + `merovingian_breaking` |

The three habits that create a compounding knowledge loop:
1. **"Catch me up"** at session start
2. **"Check before you start"** before coding
3. **"Commit and remember"** instead of just "commit"

---

## Part X: Installation

```bash
# The MCP Suite
pip install git-sentinel        # Project intelligence
pip install niobe               # Runtime observation
pip install merovingian         # Dependency intelligence
pip install seraph-ai           # Verification intelligence
npm install -g @evointel/anno   # Web content extraction

# The Dev Loop (Claude Code plugin)
# Install from Claude Code plugin marketplace or:
# Copy dev-loop/ to ~/.claude/plugins/
```

Source: [github.com/evo-hydra](https://github.com/evo-hydra) | [evolvingintelligence.ai](https://www.evolvingintelligence.ai)

---

## Appendix A: Design Constraints

1. **No tool bloat** — No Halcyon-style 20+ tool explosions. Five focused tools.
2. **Separable sidecars** — No tight coupling. Oracle orchestrates but doesn't absorb.
3. **Local-first** — SQLite + MCP. No cloud, no Docker, no external databases.
4. **Concise output** — Pagination, truncation, ~4,000 token caps. High signal per token.
5. **Backward compatible** — Anno API/CLI/MCP surfaces are stable.
6. **Matrix naming** — Sentinel, Niobe, Seraph, Merovingian, Oracle. Anno is the exception.

## Appendix B: Prior Documents (Superseded)

This white paper consolidates and supersedes:
- `EvoIntel_Thesis_2026.md`
- `EvoIntel_MCP_Suite_Thesis.md`
- `EvoIntel_Next_Gen_Stack.md`
- `EVOINTEL_MANIFESTO.md`
- `EvoIntel_Security_Debugging_Research.md`
- `AI_Coding_Agents_Are_Blind.md` (narrative retained, data updated)
- `EvoIntel_Launch_Plan.md` (strategy retained, updated for dev loop)
- `MCP_Shortcuts.md` (absorbed into Part IX)

## Appendix C: References

### Empirical Research
- [Veracode 2025 GenAI Code Security Report](https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/)
- [Georgetown CSET — Cybersecurity Risks of AI-Generated Code](https://cset.georgetown.edu/publication/cybersecurity-risks-of-ai-generated-code/)
- [CrowdStrike — Hidden Vulnerabilities in AI-Coded Software](https://www.crowdstrike.com/en-us/blog/crowdstrike-researchers-identify-hidden-vulnerabilities-ai-coded-software/)
- [GitClear AI Code Quality 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research)
- [Qodo State of AI Code Quality 2025](https://www.qodo.ai/reports/state-of-ai-code-quality/)
- [Mutation testing vs AI coverage (TwoCents)](https://www.twocents.software/blog/how-to-test-ai-generated-code-the-right-way/)

### Standards
- [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/resource/owasp-top-10-for-llm-applications-2025/)
- [OpenSSF Security-Focused Guide for AI Code Assistants](https://best.openssf.org/Security-Focused-Guide-for-AI-Code-Assistant-Instructions)
- [NIST SP 800-218A — AI SSDF Community Profile](https://csrc.nist.gov/pubs/sp/800/218/a/final)
- [AGENTS.md specification](https://agents.md/)

### Industry Context
- [Anthropic: Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [MCP donated to Agentic AI Foundation](https://www.anthropic.com/news/donating-the-model-context-protocol-and-establishing-of-the-agentic-ai-foundation)
- [Gene Kim — The Three Developer Loops](https://itrevolution.com/articles/the-three-developer-loops-a-new-framework-for-ai-assisted-coding/)
- [Simon Willison — Not Vibe Coding](https://simonwillison.net/2025/May/1/not-vibe-coding/)
- [Cline Plan & Act paradigm](https://cline.bot/blog/plan-smarter-code-faster-clines-plan-act-is-the-paradigm-for-agentic-coding)
- [Aider lint and test docs](https://aider.chat/docs/usage/lint-test.html)
- [Kiro: Beyond Vibe Coding](https://kiro.dev/blog/introducing-kiro/)
- [Open SWE (LangChain)](https://blog.langchain.com/introducing-open-swe-an-open-source-asynchronous-coding-agent/)

---

*Evolving Intelligence AI — evolvingintelligence.ai*
*"AI coding agents aren't dumb. They're blind. And blindness isn't fixed by smarter neurons. It's fixed by better sensors."*
