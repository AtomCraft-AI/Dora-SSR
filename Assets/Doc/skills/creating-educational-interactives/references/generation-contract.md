# Educational Generation Contract

Use this contract internally whenever shaping a DoraSSR educational application.

## A. Role and Scene

Start the generated build brief with explicit identity and application context:

> You are designing an educational interactive application for **[teacher/student]** use in **[classroom demonstration/guided inquiry/independent learning/etc.]**, for **[stage] [subject]** on **[topic]**.

If the user already supplies these facts, preserve them. Do not restate private or irrelevant conversation constraints in the deliverable.

## B. Required Design Slots

1. **Target user and learning stage**
2. **Learning objectives** — observable verbs, normally 1–3
3. **Knowledge model** — variables, concepts, relationships, procedure, text evidence, rules, or system state that actually drive the interaction
4. **Likely misconceptions** — only those relevant to feedback
5. **Teaching strategy** — demonstration, inquiry, comparison, practice, debugging, creation, etc.
6. **Visual information design** — what must be visible to reason correctly
7. **Interactive elements** — manipulable objects, controls, cards, blocks, timelines, maps, dialogue choices, etc.
8. **Learning loop** — action → system response → observation → reasoning → retry/advance
9. **State and data rules** — what changes when an input changes
10. **Feedback** — success, mistake, hint, explanation
11. **Teacher controls or student progression**
12. **Completion evidence** — what proves the objective was met
13. **Accuracy constraints**

## C. UI Priorities

Educational UI hierarchy should normally be:

1. current task/question;
2. learning workspace;
3. result/feedback;
4. controls/reference information;
5. optional decoration.

Do not let decoration obscure variables, evidence, labels, units, instructions, or current program execution.

## D. State Integrity

For every interactive variable, define:

- valid range or possible states;
- dependencies;
- visual effect;
- data/text effect;
- reset behavior;
- comparison behavior if applicable.

A simulation must not be a prerecorded animation pretending to respond to variables.

## E. Minimal Gamification Rule

Use narrative, goals, progress, discovery, and challenge freely when they support attention and meaning. Add points, coins, lives, streaks, combat, shops, loot, or rankings only when they reinforce the learning model. Otherwise omit them.

## F. Completion

Do not end on “Congratulations” alone. End with an artifact or evidence: a result card, comparison table, explanation, successful program, annotated text, relationship map, optimized solution, or created work.
