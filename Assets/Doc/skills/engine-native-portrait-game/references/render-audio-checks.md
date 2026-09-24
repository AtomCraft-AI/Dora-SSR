# Render and audio checks

## Engine-rendered scene

- Depth: distinct foreground, active play plane, middle distance, and far atmosphere; contrast and detail should decrease with distance.
- Value hierarchy: judge the screenshot in grayscale. The player and targets should stay distinct from the play plane; distant scenery should not be darker or sharper than nearby hazards. Increase material visibility in a large dark wall before adding more decorative objects.
- Material: vary contours, highlights, occlusion, and texture at the scale of the object. Use seeded procedural variation so frames are stable. A shader can supply continuous cloud, water, grain, or light behavior; line work and silhouettes provide authored details.
- Coverage: render a continuous base under every gameplay region before adding cliffs, islands, actors, or fog. An uncovered gap may expose the engine clear color even when the surrounding scene looks finished.
- Lighting: choose a source, then put highlights, reflections, shadows, and effects in physically related places. A glow should not become an opaque disc or obscure gameplay.
- Glow: inspect at full size for visible concentric rings from repeated translucent circles. Prefer a smooth radial falloff in a shader, Canvas, or sufficiently fine alpha gradient; keep the bright core smaller than the gameplay silhouette.
- Composition: inspect at 540×960 and approximately 270×480. Actors and HUD must still read in two seconds. Never bake UI or moving objects into the background.
- Phone-size rejection check: at 270×480, identify the player, immediate goal, safe play space, and next touch action without zooming. If any one is ambiguous, change scale, value, or framing before adding texture. In dark scenes, reject a continuous near-black area that consumes roughly a third of the active viewport without readable material or useful negative space; lift the midtones and separate the gameplay corridor from foreground framing.
- Reference check: when the user supplies sample games, compare the engine capture beside them for palette restraint, shape language, density, lighting, and material richness. Record the largest specific gap. Do not reproduce a reference by importing its bitmap; implement the relevant treatment through engine drawing and code.
- Identity: check what each actor actually resembles in the captured frame. A silhouette with a generic fin may read as a shark instead of a whale; use the defining anatomy or prop, then recheck at phone size.
- Occlusion: capture transient messages and effects as well as the clean scene. Keep rewards, warnings, and light cones from covering the focal object, a critical HUD value, or the input path.
- Cost: watch draw calls, shader switches, allocations, and frame pacing in Dora. Precompute stable detail or draw it to a Canvas when repeated per frame work is expensive. Measure before optimizing.

## Code-synthesized audio

- Map events to a small sonic vocabulary: input tick/turn, reward, error/loss, hazard, and optional ambience. Give each a recognizable frequency movement and envelope.
- For Love, make short `love.sound.newSoundData` buffers and play them with `love.audio.newSource`; verify TypeScript-to-Lua call conventions and the actual runtime log. For Dora host code, use the installed engine's own audio generation/playback APIs and exact docs.
- If a Love module function fails with a “bad self” error after TypeScript compilation, inspect its emitted Lua and the project-local declaration. Module functions must compile to `love.graphics.foo(...)`, while object methods such as `source:play()` use a receiver. Correct the local declaration or call site only after confirming the runtime signature.

If the project's TypeScript-to-Lua declarations emit an extra receiver, a function reference with `this: void` can prevent an extra `nil` argument when an alias is needed:

```ts
const makeShader = love.graphics.newShader as unknown as
  (this: void, source: string) => Love.Shader;
const shader = makeShader(source);
```

Inspect the emitted Lua: the call must be `makeShader(source)`. A plain cast without `this: void` can emit `makeShader(nil, source)`, which still fails at runtime.

- Test on the target device or host. Check that cues trigger once, do not click at their boundaries, do not mask one another, and are audible without being much louder than the rest of the game.

## Iteration note

For each pass record: capture path and state, one visible problem, the exact rendering/audio change, and the observed result. Prefer a concrete correction such as “distant islands too dark and merge with actors” over “make it prettier.”
