# Behavioral Regression Scenarios

These scenarios are intended for manual or agent-evaluation runs. The expected behavior describes what the skill must cause; it is not a user-facing template.

| # | User request | Expected routing | Must happen | Must not happen |
|---|---|---|---|---|
| 1 | “做一个小学三年级分数课件” | math + visualization | manipulate area/number-line representations; connect to fractions | generic quiz-only game |
| 2 | “初中凸透镜成像互动实验” | physics + virtual lab | drag object/lens/screen; rays/image update; compare trials | fixed animation ignoring positions |
| 3 | “高中化学平衡” | chemistry + system simulation/inquiry | concentration/temperature changes affect modeled equilibrium; label simplification | magic color effect with no chemical model |
| 4 | “做一个细胞分裂课件” | biology + visualization | step/scrub phases, inspect chromosome/state changes | treating phases as unrelated pictures |
| 5 | “《孔乙己》互动课件” | Chinese + narrative/evidence | perspective/evidence collection; distinguish invented branch from text | invented dialogue presented as original |
| 6 | “英语点餐练习” | English + dialogue role-play | communicative goal; multiple valid phrases; contextual feedback | single memorized sentence only |
| 7 | “工业革命互动课件” | history + map/timeline/evidence | chronology + geography + sources; cause/continuity comparison | ahistorical “choose best country” scoring |
| 8 | “板块运动模拟” | geography + system simulation | plate direction/speed changes affect boundaries/process view | unexplained map animation |
| 9 | “做一个人大制度课堂互动” | civics + evidence/process | institution/process understanding, source/case analysis | partisan persuasion or loyalty scoring |
| 10 | “小学生学习循环积木编程” | programming + block programming | blocks execute visibly; current block highlight; retry/debug | actor moves without code |
| 11 | “设计承重桥梁的 STEM 活动” | engineering + creation studio | constraints, build-test-revise, functional feedback | cosmetic part placement with arbitrary score |
| 12 | “色彩冷暖对比美术课件” | art + creation/visualization | manipulate palette/composition; compare effects; rationale | one ‘correct’ artwork |
| 13 | “节奏型学习小游戏” | music + creation/visualization | sound synchronized with beat grid; create/compare rhythms | visual beat unsynchronized with audio |
| 14 | “篮球挡拆战术课堂演示” | PE + simulation | position players, choose tactical action, visualize consequences | claims to assess learner's real physical ability |
| 15 | “设计一个校园节能方案项目课” | interdisciplinary + creation/inquiry | integrate math/science/engineering evidence into one artifact | disconnected quizzes from several subjects |
| 16 | “牛顿炮台，教师上课用” | physics + virtual lab + teacher orchestration | pause/reset/overlay trials/reveal trajectory | mandatory coins/lives/levels |
| 17 | “自动农场积木编程，给学生自己玩” | programming + block programming | progressive sequence→loop→condition; hints before solution | immediate full answer after first error |
| 18 | “酸碱滴定虚拟实验” | chemistry + virtual lab | procedural steps, endpoint, measurements, repeat trials, error analysis | merely click ‘start’ and watch animation |

## Pressure Checks

A correct skill response should resist these shortcuts even when the user asks for “更好玩”:

- Add entertainment only when it preserves the learning action.
- Do not replace the model with unrelated combat/running/collection.
- If a requested mechanic would distort subject truth, keep the engaging theme but redesign the mechanic.

A correct response should also resist over-design:

- If a slider + graph teaches the concept better than a world map, use the slider + graph.
- If a short evidence workspace teaches close reading better than a branching 30-minute story, use the evidence workspace.
