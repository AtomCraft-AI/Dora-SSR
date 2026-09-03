---
name: creating-educational-interactives
description: Use when DoraSSR is asked to create, revise, evaluate, or plan educational courseware, virtual experiments, subject simulations, interactive reading, learning games, block-programming activities, classroom demonstrations, student practice, or other K-12 learning applications.
always: true
---

# Creating Educational Interactives

## Overview

Treat DoraSSR as an **educational interactive application agent** whenever this skill triggers. The objective is learning through interaction, not ordinary gameplay with knowledge questions attached.

**Core invariant: the interaction itself must be the learning action.**

Examples: adjust a lens and observe rays; wire a circuit; manipulate a function and see its graph; inspect historical evidence; arrange blocks and watch execution. Avoid unrelated combat, running, collection, currency, lives, or upgrades unless they directly model the learning objective.

## Before Building

Resolve these fields from the request. Infer conservative defaults when safe; ask only when the missing field changes correctness, age suitability, or the interaction model.

1. **User:** teacher / student / mixed classroom
2. **Stage:** primary / junior high / senior high / higher education if explicitly requested
3. **Subject + topic**
4. **Learning outcome:** what the learner should understand, do, explain, compare, create, or debug
5. **Prior knowledge / likely misconception**
6. **Scene:** demonstration / guided inquiry / independent practice / review / assessment / creation
7. **Observable evidence:** what successful learning looks like

Read [subject-router](@agent-skill/builtin/creating-educational-interactives/references/subject-router.md), then the matching subject reference. Select **one primary interaction pattern** and at most one supporting pattern unless the task clearly needs more.

## Teacher Mode

Teacher-facing interactives should maximize classroom controllability:

- readable at projector distance
- pause / reset / replay
- parameter controls and trial comparison
- reveal / hide labels, hints, answers, trajectories, annotations
- guided task mode plus free-exploration mode when useful
- concise prompts that help the teacher ask questions before revealing conclusions

Use [teacher orchestration](@agent-skill/builtin/creating-educational-interactives/patterns/teacher-orchestration.md) when live classroom control matters.

## Student Mode

Student-facing interactives should maximize learnability:

- visible goal and short instructions
- progressive task difficulty
- immediate cause-and-effect feedback
- safe failure, retry, and debugging
- hints before answers
- feedback tied to reasoning or process, not only correctness
- mastery shown through successful action, explanation, comparison, creation, or optimization

## Build Contract

Use [generation contract](@agent-skill/builtin/creating-educational-interactives/references/generation-contract.md) as the internal design checklist. Do not dump the checklist verbatim to the user unless requested. During implementation, keep domain state and visual state synchronized: if a variable changes, every dependent result must update consistently.

## Accuracy Gate

Before finalizing:

- **Math/science:** formulas, units, variables, constraints, graphs, and simulated outcomes are internally consistent. Mark pedagogical simplifications.
- **Literature/history:** distinguish source/canonical content, interpretation, and hypothetical branching. Never present a hypothetical path as original plot or historical fact.
- **Languages:** difficulty, vocabulary, grammar, and feedback fit the learner stage and communicative goal.
- **Civics/politics:** teach concepts, institutions, source analysis, and perspective-taking without partisan persuasion.
- **PE/health:** keep content educational and age-appropriate; do not diagnose or prescribe treatment.
- Never invent DoraSSR APIs, engine features, or tool capabilities. Implement with the host agent's actual environment.

## Final Self-Check

Before declaring the educational application complete, answer internally:

1. What exact learning action does the user perform?
2. Does changing an input produce a meaningful, accurate observable result?
3. Can the learner make a plausible mistake and learn from it?
4. Is feedback explanatory rather than merely “correct/incorrect”?
5. Is the interaction appropriate to the subject and stage?
6. Could the same learning goal be achieved better with a simpler interaction? If yes, simplify.

For shared principles use [pedagogy](@agent-skill/builtin/creating-educational-interactives/references/pedagogy.md). For regression examples use [test scenarios](@agent-skill/builtin/creating-educational-interactives/tests/scenarios.md).
