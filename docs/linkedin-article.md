# Three Ways to Code with AI: Persistence, Specifications, and Intelligence

*A comparison of the Ralph Wiggum Loop, Kiro's Spec-Driven Development, and Morpheus — and what each reveals about where AI-assisted coding is headed.*

---

I've spent the last year building tools for AI-assisted development. During that time, I've watched the conversation evolve from "can AI write code?" to the much harder question: "how do we make sure the code it writes is any good?"

Three approaches have emerged that take fundamentally different bets on that question. I've used all three. Here's what I've learned.

---

## The Ralph Wiggum Loop: Persistence

The Ralph Wiggum technique, created by Geoffrey Huntley and formalized into an official Claude Code plugin by Anthropic, is elegant in its simplicity.

It's a `while true` loop.

You give Claude a prompt and a "completion promise" — a phrase it can only output when the work is genuinely done. Claude works on the task, tries to exit, and a hook intercepts the exit. If the promise isn't found, the same prompt goes back in. Claude sees its previous work in the files, reads the git history, and tries again.

That's it. No intelligence layer. No quality gate. No external tools. Just relentless iteration until the task is complete.

**What it gets right:**

The self-referential insight is genuinely brilliant. By making Claude see its own previous work on each loop, it turns a stateless model into an iterative problem solver. The completion promise mechanism is a clever forcing function — the AI can't claim victory until it actually delivers.

This approach works remarkably well for tasks with clear, verifiable end states: "make all tests pass," "implement this feature until the app runs," "fix this bug." The loop handles the unpredictability of AI outputs by simply trying again.

**What it doesn't address:**

Ralph doesn't know anything about your project. It can't tell Claude that `bank_connection.py` has been a source of bugs for six months, or that files A and B always change together, or that the team uses snake_case in Python but camelCase in API responses. Each iteration starts with the same context: the prompt and whatever Claude can infer from reading files.

There's no quality gate beyond "the promise was fulfilled." If Claude writes code that passes tests but introduces a security vulnerability, or creates a parallel type that already exists elsewhere in the codebase, or breaks an API contract that a downstream service depends on — the loop doesn't catch it. It only knows: did the promise text appear?

Ralph is a workhorse. It will grind through problems with admirable persistence. But it's grinding blind.

---

## Kiro: Specifications

Kiro, Amazon's agentic IDE that went generally available in late 2025, takes the opposite approach. Instead of iterating toward a solution, it front-loads the thinking.

You describe what you want in natural language. Kiro generates user stories with acceptance criteria, a technical design document, and a list of implementation tasks. Code is then written against these specs. Hooks trigger on file changes to enforce consistency.

The philosophy: if the spec is right, the code will be right.

**What it gets right:**

Spec-driven development addresses a real failure mode of AI coding. Without a spec, the AI interprets your vague request however it wants, and you discover the misinterpretation after it's already built the wrong thing. Kiro forces the design conversation to happen before a single line of code is written.

For complex features — a new authentication flow, a database migration, a multi-service integration — this is genuinely valuable. The spec becomes a contract between you and the AI. When the implementation drifts, you can point to the spec and say "that's not what we agreed on."

Kiro also has the backing of AWS, deep integration with AWS CDK and CloudFormation, and the resources to build a polished IDE experience.

**What it doesn't address:**

Kiro's intelligence is forward-looking: it generates specs from your description. But it doesn't look backward at your project's history. It doesn't know which files are fragile, what patterns the codebase follows, or what mistakes have been made before. The spec is written in a vacuum — informed by the AI's general knowledge, not by your project's specific context.

And once the code is written, Kiro validates it against the spec. That's valuable, but it doesn't tell you whether the tests actually verify anything meaningful. A test that achieves 100% line coverage while catching only 4% of injected mutations — a documented reality of AI-generated tests — would pass spec validation just fine.

Kiro makes the AI a better planner. It doesn't make the AI a better observer.

---

## Morpheus: Intelligence

Morpheus is what I built after watching both approaches miss the same thing.

The problem isn't persistence (Ralph has that) or planning (Kiro has that). The problem is that AI agents are structurally blind — to project history, to runtime behavior, to cross-service dependencies, to code quality beyond test passage. No amount of iterating or spec-writing fixes what the agent literally cannot see.

Morpheus is an autonomous dev loop for Claude Code that connects the AI to four MCP servers before, during, and after coding:

**Before coding (CHECK):** Sentinel surfaces your project's institutional memory — conventions extracted from git history, pitfalls from past bug fixes, files that historically change together, architectural decisions with rationale. When Claude is about to modify a fragile file, it knows the last three times someone broke it and how.

**During coding (FDMC):** Every task runs through a four-lens quality critique — Future-Proof, Dynamic, Modular, Consistent — with concrete red flags. The Consistent lens, which I've found is violated most often, forces the agent to check: how are similar systems structured in this codebase? Where do they live, who owns them, how are they wired in? Match the pattern.

**After coding (GRADE):** Seraph runs mutation testing on the diff — deliberately injecting bugs and checking whether the tests catch them. A surviving mutation means the test doesn't actually verify that behavior. This is the only honest measure of test quality, and it routinely reveals that "all tests pass" means almost nothing.

**After every task (COMMIT):** Sentinel saves what was learned — error fingerprints, solutions, pitfalls — so the next session doesn't start from scratch.

**After the plan completes (CLOSE):** Feedback is submitted to every MCP server, closing the learning loop so intelligence compounds over time.

**What it gets right:**

Morpheus doesn't just iterate (though it does — failed tests trigger retry with solution search). It doesn't just plan (though it works from structured plan files). It gives the AI sight into things it structurally cannot reach on its own:

- Sentinel sees 6 months of git history that no context window can hold
- Seraph sees whether tests actually verify anything, not just whether they pass
- Niobe sees runtime metrics that require process observation, not code reading
- Merovingian sees API contracts across repositories that span the AI's field of vision

**What it doesn't address (yet):**

Morpheus reviews its own code through the FDMC lenses. That's better than no review, but self-critique has inherent bias. Anthropic's own recommendation is two separate sessions — one writes, a fresh one reviews. A dedicated reviewer subagent with a clean context window would be stronger.

And unlike Kiro, Morpheus doesn't generate specs. For complex features, a specification layer before task decomposition would catch design issues earlier than the current plan-then-code approach.

---

## What Each Approach Reveals

These three tools aren't really competing. They're solving different layers of the same problem:

| Layer | Ralph Wiggum | Kiro | Morpheus |
|-------|-------------|------|----------|
| **Persistence** | Core strength | Not focus | Built in (retry + solution search) |
| **Planning** | None | Core strength | Plan files (lighter than specs) |
| **Project intelligence** | None | None | Sentinel (conventions, pitfalls, co-changes) |
| **Quality verification** | Promise fulfilled | Spec validated | Mutation testing + FDMC critique |
| **Runtime awareness** | None | None | Niobe (process metrics, logs) |
| **Contract safety** | None | AWS integration | Merovingian (API breaking changes) |
| **Knowledge persistence** | None | None | solution_save across sessions |
| **Feedback loop** | Self-referential (files) | Spec → code → validate | MCP feedback to all servers |

Ralph bets that persistence is enough. Keep trying and you'll get there.

Kiro bets that planning is enough. Get the spec right and the code follows.

Morpheus bets that intelligence is enough. Give the AI sight and it makes better decisions at every step.

The truth is probably that you need all three. Persistence for grinding through hard problems. Specifications for complex features where design matters. Intelligence for everything the AI can't see on its own.

---

## Where This Is Going

The AI coding landscape is moving fast. Vibe coding — Andrej Karpathy's term for "forget that the code even exists" — was the word of the year in 2025. By early 2026, Karpathy himself said vibe coding is "passe," replaced by "agentic engineering."

The tools are maturing in the same direction:

- **MCP is now an industry standard.** Anthropic donated it to the Agentic AI Foundation (Linux Foundation), co-governed with OpenAI and Block. 97M+ monthly SDK downloads. This is the universal protocol for giving AI agents access to external intelligence.

- **Multi-agent architectures are emerging.** Writer/Reviewer, Planner/Executor, Architect/Programmer — the pattern of specialized agents collaborating is replacing the monolithic "one AI does everything" model.

- **Verification is the bottleneck.** Qodo's 2025 research found only 3.8% of developers report both low hallucinations AND high confidence shipping AI code. The generation problem is mostly solved. The verification problem is wide open.

I built five MCP servers and an autonomous dev loop because I got tired of finding bugs that the AI was blind to. Six user-ID bugs in a fintech app where every test passed. Repeated mistakes because the AI couldn't remember what it learned last session. Breaking changes that crossed repository boundaries.

The models are good enough. The infrastructure around them isn't.

If any of this resonates, try one tool this week. `pip install git-sentinel` and run `sentinel init` on your biggest project. Then ask your AI agent: "check before you start."

You might be surprised what it tells you.

---

*The tools described in this article are open source:*

- **Morpheus** (the dev loop): `git clone https://github.com/evo-hydra/morpheus ~/.claude/plugins/morpheus`
- **Sentinel** (project intelligence): `pip install git-sentinel`
- **Seraph** (mutation testing): `pip install seraph-ai`
- **Niobe** (runtime observation): `pip install niobe`
- **Merovingian** (API contracts): `pip install merovingian`

*Source: [github.com/evo-hydra](https://github.com/evo-hydra) | [evolvingintelligence.ai](https://www.evolvingintelligence.ai)*

---

*#AIEngineering #MCP #DevTools #OpenSource #ClaudeCode #Morpheus #TheFiveBlinnesses*
