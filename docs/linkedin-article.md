# I Gave AI Agents Eyes. Then I Realized They Still Couldn't Think.

*A follow-up to "AI Coding Agents Are Blind" — what happened after I built the sensors, and why the best AI coding techniques are better combined than competing.*

---

Two weeks ago I published "AI Coding Agents Are Blind." I laid out five structural blind spots that no model improvement will ever fix — project history, runtime behavior, cross-service dependencies, code quality beyond "tests pass," and web content buried in HTML noise. I described the five MCP tools I built to fix them: Sentinel, Niobe, Merovingian, Seraph, and Anno.

The response was more than I expected. But the most common question wasn't about the tools.

It was: *"OK, I installed Sentinel. Now what? When do I call it? How does it fit into my workflow?"*

Fair question. I had built five sensors and handed them to people without an instruction manual. The tools could see — but nobody had told them *when* to look.

So I built that too. And in the process, I discovered something I didn't expect: the orchestration layer that connects these tools works even better when it borrows from two techniques I didn't invent.

---

## The Missing Brain

Here's what I had after the original article: five tools that give AI agents sight. Sentinel sees project history. Niobe sees runtime. Merovingian sees API contracts. Seraph sees test quality. Anno sees clean web content.

Here's what I didn't have: anything that tells the agent to actually use them.

I'd start a coding session, write code, remember to check Sentinel halfway through, forget to run Seraph, commit without saving what I learned. The tools were available. The workflow was still manual.

The tools were eyes. What I needed was a brain — something that orchestrates the entire development cycle: check intelligence before coding, critique the code after writing it, grade it with mutation testing, commit it with knowledge persistence, and loop to the next task.

I called it Morpheus. Named after the Matrix character who shows Neo the truth. Because that's what it does — it connects the agent to reality through Sentinel, Niobe, Seraph, and Merovingian in a structured cycle:

```
BOOTSTRAP → CHECK → CODE → TEST → CRITIQUE → GRADE → COMMIT → ADVANCE
```

For each task in a plan, Morpheus runs every phase in order. No human input between tasks. It checks Sentinel for pitfalls before coding. It critiques its own diff for structural violations after coding. It runs mutation testing through Seraph before committing. It saves solutions and pitfalls to Sentinel after committing. When the plan is done, it submits feedback to every MCP server so they get smarter for next time.

The first time I ran Morpheus against a real project — 12 tasks, 11 commits, ~4,800 lines of code — it worked. But it also taught me something humbling.

---

## What Morpheus Got Wrong

I built Morpheus to use my MCP tools. On the first real run, it used 4 out of 32 available tools. Four.

Sentinel wasn't initialized on that project. Morpheus called it, got an error, and gave up — for all 12 tasks. It never tried again. It never offered to initialize it. It just coded blind for the rest of the session.

Seraph was called once, with the mutation testing disabled (I had set `skip_mutations=true` to save time). The grade came back A — across 3 of 6 dimensions, with nothing actually tested. An empty gold star.

Niobe and Merovingian were never called at all.

I'd built a brain that had eyes it refused to open.

So I rewrote the protocol. Morpheus v2 probes all servers once at the start (not per task), caches what's available, and uses everything it can. Seraph runs with mutations enabled by default. Sentinel saves solutions after every bug fix. Feedback goes to all servers at the end of every plan.

But the rewrite taught me something bigger: orchestration isn't just about my tools.

---

## The Three Layers Nobody's Combining

While I was building the intelligence layer, two other approaches had gotten popular. And instead of competing with them, I realized they solve completely different problems.

### Layer 1: Persistence — Ralph Wiggum

Geoffrey Huntley created the Ralph Wiggum technique, and Anthropic formalized it into an official Claude Code plugin. The concept is deceptively simple: a `while true` loop that feeds the same prompt to Claude over and over. Each time Claude sees its previous work in the files and tries again. A "completion promise" mechanism stops the loop only when the task is genuinely done.

Ralph solves a problem I've felt a hundred times: the AI gives up too early. It writes code, hits an error, and says "I've encountered an issue." Ralph doesn't let it quit. It intercepts the exit and feeds the prompt back in. Claude sees its own failure and iterates.

That persistence is powerful. But Ralph doesn't know anything about your project. Each iteration starts with the same information — the prompt and whatever Claude infers from reading files. There's no Sentinel surfacing pitfalls, no Seraph grading test quality, no knowledge carried between sessions. It's grinding. Effective grinding. But blind grinding.

### Layer 2: Planning — Kiro

Amazon launched Kiro as a spec-driven IDE. You describe what you want in natural language. Kiro generates user stories with acceptance criteria, a technical design, and a task list. Code is written against the spec. Hooks enforce consistency.

Kiro solves another problem I've felt: the AI builds the wrong thing because it misunderstood the requirement. Without a spec, ambiguity compounds. By the time you discover the misinterpretation, the AI has already built three layers on top of it.

That planning is valuable. But Kiro doesn't look backward at your project's history. It doesn't know which files are fragile. It doesn't run mutation testing. The spec is written in a vacuum — informed by the model's general knowledge, not by the six months of git history sitting right there in the repo.

### Layer 3: Intelligence — Morpheus

Morpheus solves what I've felt most viscerally: the AI doesn't know my project. It doesn't know that `bank_connection.py` has been a source of bugs for six months. It doesn't know that files A and B always change together. It doesn't know that the last person who touched this code introduced the exact same bug I'm watching it introduce right now.

That intelligence changes everything. But Morpheus can be too cautious — it has a maximum of 3 retries on test failures before marking a task as failed. And it doesn't generate specs — it works from simpler plan files, which are fine for focused tasks but lack the design depth that complex features need.

---

## What Happens When You Stack All Three

Here's the thing nobody is talking about: these three approaches fill each other's exact gaps.

**Ralph + Morpheus intelligence = Persistent, informed iteration.**

Instead of Ralph grinding blind through 5 iterations, inject Sentinel intelligence on each loop. Iteration 1: "This file broke 3 times before — here's why." The agent writes informed code. Tests pass. One iteration instead of five. Not because the model is smarter. Because it can see.

**Kiro specs + Morpheus plans = Design-informed task execution.**

Kiro generates the spec. Morpheus `/plan` breaks the spec into discrete, committable tasks. Each task gets Sentinel intelligence, FDMC critique, and Seraph grading. The spec prevents design misinterpretation. The intelligence prevents implementation mistakes. Neither alone covers both.

**All three together:**

```
Kiro       →  Spec (user stories, technical design, acceptance criteria)
                ↓
Morpheus   →  Plan (tasks from spec, with target files and test commands)
                ↓
             Execute each task:
               CHECK  → Sentinel: pitfalls, co-changes, conventions
               CODE   → FDMC pre-flight, then implement
               TEST   → Run tests (Ralph persistence if failures)
               GRADE  → Seraph: mutation testing + quality gate
               COMMIT → Save knowledge for next session
                ↓
             Repeat until plan complete
```

Specs catch design mistakes before coding starts.
Intelligence catches implementation mistakes during coding.
Persistence handles the remaining chaos.
Knowledge prevents repeat mistakes across sessions.

I've been running this combined workflow for the last two weeks. The difference isn't subtle. Tasks that used to take 3-5 iterations complete in 1. Bugs that used to reappear across sessions don't — because Sentinel remembers the fix. Tests that used to pass vacuously get caught by Seraph's mutation testing. API contracts that would have broken silently get flagged by Merovingian before I push.

---

## The Comparison

| Capability | Ralph Alone | Kiro Alone | Morpheus Alone | Stacked |
|-----------|------------|-----------|---------------|---------|
| Retries on failure | Unlimited | No | 3 attempts | Unlimited + informed |
| Spec-first design | No | Yes | No | Yes |
| Project history | No | No | Sentinel | Sentinel |
| Mutation testing | No | No | Seraph | Seraph |
| Runtime observation | No | No | Niobe | Niobe |
| API contract safety | No | AWS services | Merovingian | Merovingian |
| Cross-session memory | No | No | solution_save | solution_save |

No single tool fills the whole table. The stack does.

---

## Persistence Without Sight Is Grinding Blind

I started this journey running four AI coding platforms in parallel, building 114 modules to make them share one brain, and killing most of it when the models got better.

The pieces that survived became the Five Blindnesses. The orchestration I was missing became Morpheus. And the humbling realization that I wasn't using my own tools properly became the v2 protocol that actually works.

But the biggest lesson came from looking at what other people built. Ralph Wiggum's persistence. Kiro's spec-driven planning. Neither solves blindness — but I don't solve persistence or specs. And here's the thing: we don't need to.

MCP is now an industry standard — Anthropic donated it to the Linux Foundation, co-governed with OpenAI and Block. Any tool that exposes intelligence via MCP works with any agent. Ralph, Kiro, and Morpheus don't need to know about each other. They just need to work on the same codebase with the same protocol.

The era of "pick one tool" is over. The era of stacking layers has started.

If you read the original article and installed Sentinel, here's your next step: install Morpheus and let it orchestrate what Sentinel sees.

If you're already using Ralph Wiggum, add Sentinel intelligence to each loop iteration.

If you're using Kiro, feed your specs into Morpheus's plan command and let it execute with mutation testing and project memory.

The models are good enough. The infrastructure around them is getting there. And for the first time, the tools are composable enough that you don't have to choose.

Stack the layers. Give your AI the whole picture.

---

*The tools from this article and the original:*

- **Morpheus** (the brain): `git clone https://github.com/evo-hydra/morpheus ~/.claude/plugins/morpheus`
- **Sentinel** (project memory): `pip install git-sentinel`
- **Seraph** (mutation testing): `pip install seraph-ai`
- **Niobe** (runtime eyes): `pip install niobe`
- **Merovingian** (contract maps): `pip install merovingian`
- **Anno** (clean web content): `npm install -g @evointel/anno`
- **Ralph Wiggum** (persistence): Official Claude Code plugin
- **Kiro** (spec-driven planning): [kiro.dev](https://kiro.dev)

*By [Evolving Intelligence AI](https://evolvingintelligence.ai) | [github.com/evo-hydra](https://github.com/evo-hydra)*

*#AIEngineering #MCP #DevTools #OpenSource #ClaudeCode #Morpheus #AgenticEngineering #TheFiveBlinnesses*
