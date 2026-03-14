# I Gave AI Agents Eyes. They Still Needed a Brain.

*A follow-up to "AI Coding Agents Are Blind" — what happened after I built the sensors, and why the best AI coding techniques don't compete. They stack.*

---

Two weeks ago I published "AI Coding Agents Are Blind." I laid out five structural blind spots that no model improvement will ever fix — project history, runtime behavior, cross-service dependencies, code quality beyond "tests pass," and web content buried in HTML noise. I described the five MCP tools I built to fix them: Sentinel, Niobe, Merovingian, Seraph, and Anno.

The response was more than I expected. But the most common question wasn't about the tools.

It was: *"OK, I installed Sentinel. Now what? When do I call it? How does it fit into my workflow?"*

Fair question. I had built five sensors and handed them to people without an instruction manual. The tools could see — but nobody had told them *when* to look.

That's when I realized: **the era of "pick one tool" is over. The era of stacking layers has started.** And the layer I was missing wasn't another tool. It was the protocol that connects them.

---

## Sensors Alone Don't Create Workflow

Here's what I had after the original article: five tools that give AI agents sight. Sentinel sees project history. Niobe sees runtime. Merovingian sees API contracts. Seraph sees test quality. Anno sees clean web content.

Here's what I didn't have: anything that tells the agent to actually use them.

I'd start a coding session, write code, remember to check Sentinel halfway through, forget to run Seraph, commit without saving what I learned. The tools were available. The workflow was still manual.

The tools were sensors. What I needed was a protocol — structured instructions that tell Claude when to check intelligence, when to critique its own code, when to run mutation testing, and what to save for next time.

Not another tool. Not another MCP server. Just markdown that Claude follows autonomously.

I called it Morpheus. It's a Claude Code plugin — 5 markdown files, zero code, zero dependencies. It connects the agent to reality through Sentinel, Niobe, Seraph, and Merovingian in a structured cycle:

```
BOOTSTRAP → CHECK → CODE → TEST → CRITIQUE → GRADE → COMMIT → ADVANCE
```

The first time I ran it against a real project — 12 tasks, 11 commits, ~4,800 lines of code — it worked. But it also taught me something humbling.

---

## What Went Wrong on the First Run

On that first run, Morpheus used 4 out of 32 available MCP tools. Four.

Sentinel wasn't initialized on that project. Morpheus called it, got an error, and gave up — for all 12 tasks. It never tried again. It coded blind for the rest of the session.

Seraph was called once with mutation testing disabled. The grade came back A — across 3 of 6 dimensions, with nothing actually tested. An empty gold star.

Niobe and Merovingian were never called at all.

I'd built a brain that refused to open its eyes.

So I rewrote the protocol. Morpheus v2 probes all servers once at startup, caches what's available, and uses everything it can. Seraph runs with mutations enabled by default. Sentinel saves solutions after every bug fix. Feedback goes to all servers at the end.

But the rewrite taught me something bigger: my protocol wasn't the only piece of the puzzle.

---

## Four Layers, Not Four Choices

While I was building the orchestration layer, I looked at what other people had built. And instead of seeing competitors, I saw complementary layers solving different problems.

Here's the frame that changed how I think about this:

- **Sensors** give the agent visibility.
- **Protocols** give the agent sequencing.
- **Persistence loops** give the agent stamina.
- **Specs** give the agent direction.

Each of these is a layer. No single layer is sufficient. The best results come from stacking them.

### Persistence: Ralph Wiggum

Geoffrey Huntley created the Ralph Wiggum technique, which inspired Claude Code plugin implementations and broader adoption of persistent agent loops. The concept is deceptively simple: a `while true` loop that feeds the same prompt to Claude over and over. Each time Claude sees its previous work in the files and tries again. A "completion promise" mechanism stops the loop only when the task is genuinely done.

Ralph solves a problem I've felt a hundred times: the AI gives up too early. It writes code, hits an error, and says "I've encountered an issue." Ralph doesn't let it quit.

**Ralph provides stamina.** But it doesn't provide visibility. Each iteration has no knowledge of project history, no quality gate, no memory between sessions.

### Specs: Kiro

Amazon launched Kiro as a spec-driven agentic IDE. You describe what you want. Kiro generates user stories with acceptance criteria, a technical design, and a task list. Code is written against the spec. Hooks enforce consistency.

Kiro solves another problem I've felt: the AI builds the wrong thing because it misunderstood the requirement. Without a spec, ambiguity compounds.

**Kiro provides direction.** But it doesn't look backward at your project's history, doesn't know which files are fragile, and doesn't run mutation testing to check whether the tests actually verify anything.

### Orchestration: Morpheus

Morpheus is the protocol layer. For each task, it tells Claude: check Sentinel for pitfalls and co-changes before coding. Run the FDMC quality critique after coding. Grade with Seraph's mutation testing before committing. Save solutions to Sentinel after committing. Submit feedback to all servers when the plan is done.

**Morpheus provides sequencing and visibility.** But on its own, it caps retry attempts at 3 and doesn't generate specs for complex features.

---

## What Happens When You Stack All Four

Here's the part that matters: each layer fills the exact gap the others leave open.

### When Should Each Layer Fire?

This is the operational question people actually asked. Here's a concrete decision framework:

**Every task, always:**
- Sentinel pitfalls + co-changes before coding (30 seconds, prevents repeat mistakes)
- FDMC self-critique after coding (catches structural violations)
- Tests after implementation (basic hygiene)

**When tests fail:**
- Sentinel solution search first ("have we seen this before?")
- Ralph-style persistence if the fix needs multiple attempts

**When the task touches auth, payments, schemas, or shared API contracts:**
- Seraph with mutations enabled before commit (a failed mutation gate blocks commit)
- Merovingian contract check before advancement (a breaking change blocks the task)

**When the task modifies infrastructure, queues, or performance-sensitive code:**
- Niobe snapshots before and after (compare runtime metrics)

**When the feature is complex enough to design wrong:**
- Spec first (Kiro-style) before creating the Morpheus plan

**After every plan completes:**
- Feedback to all MCP servers (closes the learning loop)

That's not "use all tools all the time." It's "use the right layer at the right moment."

### The Combined Stack in Practice

```
Spec (Kiro-style)  →  Design: user stories, acceptance criteria, data model
                        ↓
Morpheus /plan     →  Tasks: ordered, with target files and test commands
                        ↓
For each task:
  CHECK            →  Sentinel: pitfalls, co-changes, conventions
  CODE             →  FDMC pre-flight, then implement
  TEST             →  Run tests (Ralph persistence if failures)
  CRITIQUE         →  FDMC self-review with red flags
  GRADE            →  Seraph: mutation testing + quality gate
  COMMIT           →  Save knowledge for next session
                        ↓
CLOSE              →  Feedback to all MCP servers
```

Specs catch design mistakes before coding starts.
Sensors catch implementation mistakes during coding.
Protocols ensure nothing gets skipped.
Persistence handles the remaining chaos.
Knowledge prevents repeat mistakes across sessions.

### The Stacked Comparison

| Capability | Ralph Alone | Kiro Alone | Morpheus Alone | Stacked |
|-----------|------------|-----------|---------------|---------|
| Retries on failure | Unlimited | No | 3 attempts | Unlimited + informed |
| Spec-first design | No | Yes | No | Yes |
| Project history | No | No | Sentinel | Sentinel |
| Mutation testing | No | No | Seraph | Seraph |
| Runtime observation | No | No | Niobe | Niobe |
| Cross-session memory | No | No | solution_save | solution_save |

No single layer fills the whole table. The stack does.

---

## The Broader Shift

This isn't just about my tools. The AI coding landscape is moving toward composition.

**MCP is now an industry standard.** Anthropic donated the Model Context Protocol to the Agentic AI Foundation, a Linux Foundation-directed fund, with Anthropic, OpenAI, and Block among the co-founding contributors. 97M+ monthly SDK downloads. Any tool that exposes intelligence via MCP can plug into any agent.

**Verification is the bottleneck.** Qodo's 2025 research: only 3.8% of developers report both low hallucinations AND high confidence shipping AI code. The generation problem is mostly solved. The quality problem is wide open.

**Multi-layer architectures are emerging.** Writer/Reviewer, Planner/Executor, Sensor/Protocol — the pattern of specialized components collaborating is replacing the monolithic "one approach does everything" model.

I built five MCP sensors and a protocol because I got tired of finding bugs that the AI was blind to. Six user-ID bugs in a fintech app where every test passed. Repeated mistakes because the AI couldn't remember what it learned last session. Breaking changes that crossed repository boundaries.

The models are good enough. The infrastructure around them is getting there. And for the first time, the tools are composable enough that you don't have to choose.

Stop choosing. Start stacking.

---

*The protocol (just markdown — zero dependencies):*

- **Morpheus**: `git clone https://github.com/evo-hydra/morpheus ~/.claude/plugins/morpheus`

*The MCP sensors it orchestrates (optional — install what you need):*

- **Sentinel** (project memory): `pip install git-sentinel`
- **Seraph** (mutation testing): `pip install seraph-ai`
- **Niobe** (runtime observation): `pip install niobe`
- **Merovingian** (contract maps): `pip install merovingian`
- **Anno** (clean web content): `npm install -g @evointel/anno`

*Complementary layers (different problems, same goal):*

- **Ralph Wiggum** (persistence): Claude Code plugin
- **Kiro** (spec-driven planning): [kiro.dev](https://kiro.dev)

*By [Evolving Intelligence AI](https://evolvingintelligence.ai) | [github.com/evo-hydra](https://github.com/evo-hydra)*

*#AIEngineering #MCP #DevTools #OpenSource #ClaudeCode #Morpheus #AgenticEngineering*
