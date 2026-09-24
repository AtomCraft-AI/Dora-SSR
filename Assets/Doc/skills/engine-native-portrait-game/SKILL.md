---
name: engine-native-portrait-game
description: Create or improve a portrait mobile mini-game in Dora SSR using only engine code for its visuals and sound effects, then inspect the running game and iterate on visible and audible defects.
---

# Engine-native portrait game

Use this skill for a playable 9:16 Dora SSR game or a visual/audio upgrade to one. The result must be a complete game, not a static scene or an art mockup.

## Work with Dora's built-in skills

This skill adds portrait-game art direction and acceptance checks; it does not replace Dora's built-in coding rules.

- `dora-engine-coding` is always active for the Dora host. If the project uses `LoveNode`, read `@agent-skill/builtin/love-game-development/SKILL.md` and classify each file by runtime. The host uses Dora APIs and centered, positive-Y-up coordinates; the isolated Love game uses `love.*` and its top-left, positive-Y-down design surface. Look up unfamiliar APIs in the matching `dora-api` or `love-api` docs.
- For a native Dora HUD, read `@agent-skill/builtin/ui-design/SKILL.md`. For a Love HUD, apply its visual hierarchy checks but draw inside the Love state without importing DoraX or Dora UI modules there.

## Shape the game first

Write a compact brief before coding: one unusual but teachable mechanic, a 30–90 second loop, one-finger input, a visible win/loss condition, target portrait surface, and a two-line art direction. Specify a controlled palette with at least one warm/cool contrast and the intended material and lighting. Leave room to refine the idea after seeing it run.

Mark the phone's safe zones, HUD, moving-object paths, hazard area, and touch area. Give the player, target, and hazard different silhouettes and values at small display size.

Before drawing, assign each depth plane a color/value range and a material technique: continuous sky/ground field, distant silhouettes, active play surface, foreground framing, local light, and actor detail. Choose two distinctive scene details that express this game's setting. This prevents a generic gradient with unrelated shapes.

## Use the engine as the art and audio source

- Create all scene art in Dora runtime code. Use the supported DrawNode/VGNode/nvg path, or Love2dNode's `love.graphics` drawing, Canvas, Mesh, and Shader APIs after checking the available signatures. Build backgrounds from depth planes, atmospheric perspective, varied contours, material detail, and a consistent light source. Use animation to make water, fog, foliage, particles, or other materials feel alive. A stack of flat rectangles, circles, and triangles with a palette swap is not a finished scene.
- Draw game actors in the same camera, scale, edge treatment, and lighting as the environment. Preserve clear silhouettes. Keep all decorative work out of collision and game-rule calculations.
- Give each large object a silhouette pass, a shaded volume pass, and a material/detail pass. Make the near plane materially legible without letting its contrast defeat the actors. Keep luminous accents smooth; visible concentric rings and hard rectangular halos are defects to fix after a screenshot.
- Synthesize sound with engine code. Every game needs audible feedback for its primary input, success, failure, and a meaningful warning or state transition. In a Love game, use Love `SoundData`/`Source` within its isolated state. In a native Dora game, read `@agent-skill/builtin/music-generation/SKILL.md` when its tools are available: a typed score or composition uses engine synthesis to create WAV/OGG, which the Dora audio API then plays. For a strict code-only, resource-independent result, choose its built-in instruments rather than a SoundFont or downloaded media. Do not call Dora's generator from the Love state. Give cues short envelopes and distinct pitch/timbre so the player can tell events apart. Keep gain restrained and provide a way to mute when the game's UI calls for it.
- Do not call external image or audio generation services, download assets, or add externally made media to complete this workflow. The engine's own code-driven audio synthesis is allowed. Compiler output and screenshots used for QA are not game assets.

## Build a complete vertical slice

Implement title/instructions, active play, clear feedback, win and loss, and restart. Keep the input loop simple enough to explain in one sentence. For Love2dNode projects, keep `love.*` inside the Love game and Dora APIs in the host entry; build TypeScript to Lua and launch through the Dora host.

Read `@agent-skill/builtin/engine-native-portrait-game/references/render-audio-checks.md` when selecting procedural techniques or reviewing a run.

## Iterate from the running game

1. Build the authored source and launch it in Dora. Check logs for draw, shader, sound, and input errors.
2. Capture at least title and active play with actors present from the actual engine. Inspect full size and at phone size. Check hazard/feedback and results during play, capturing additional states when useful. Listen for each required cue through gameplay or a brief debug trigger. Do not build an elaborate test-only state machine merely to collect screenshots.
3. Name the most harmful visible or audible defect and change the responsible code. Capture and listen again. Continue until the scene has clear depth and material, actors remain readable over it, audio events are distinguishable, and each game state is intentional.
4. Test touch, aspect ratio/cropping, restart, and win/loss paths. Remove temporary QA triggers before delivery. Record unverified states plainly; compilation alone does not prove playability or art quality.

When refining this skill itself, use an independently conceived game as the test. Turn each observed defect into a transferable rendering, audio, or inspection rule, then apply the revised skill on the next pass. Do not encode the test game's theme, positions, colors, or mechanics as universal instructions. If the latest capture still misses the requested visual bar, name that gap instead of declaring the skill proven.

When maintaining Dora's built-in skill, edit `Assets/Doc/skills/engine-native-portrait-game/` in the engine repository and test the guidance with an independent game. A game project may override it under `.agent/skills/engine-native-portrait-game/` only when that project needs a deliberate variant. For an ordinary game request, deliver the game and representative engine captures; do not recreate or rewrite the skill merely because it was used. Keep generated screenshots out of the game's content directory.
