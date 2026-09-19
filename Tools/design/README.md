# Go native visual resources

`go-materials.html` is a self-contained snapshot of the approved GoModel material CSS. It produces static cartridge and console textures. The application never loads HTML or a WebView; live artwork, text, layout, gestures and navigation use Dora nodes.

Functional icons use [Lucide](https://lucide.dev), pinned in `package-lock.json`. Run `npm ci --prefix Tools/design`, then `npm run icons --prefix Tools/design`. `export-go-icons.cjs` exports only the named subset as white 72px textures (24px at 3×, 1.7px stroke). `GoIcon` supplies runtime size and tint; `icons.json` records source names/version and the upstream license is bundled with the textures. Add icons to this mapping and `GoIconName`, rather than drawing new paths or using font glyphs. The full icon package and SVG renderer are build dependencies only.

`Mobile/Motion.ts` supplies shared centered press feedback, leaving native touch bounds unchanged and resuming from the current animated value. Feed dragging uses the live card pose, 230ms cancellation, a 400ms turn/alignment plus 160ms insertion, and a 180ms seated hold before launch. System reduced-motion skips decorative transforms.

The cartridge is 236 × 308 logical pixels with a 24 px transparent shadow margin. Textures are exported at 3×. The live cover rectangle is (26, 59, 184, 167) in top-left HTML coordinates, or (26, 82, 184, 167) in bottom-left Dora coordinates.

To regenerate, serve the repository on localhost port 4182 and use Playwright CLI from the repository root:

```powershell
python -m http.server 4182 --bind 127.0.0.1
# In another terminal:
npx --package @playwright/cli playwright-cli -s=go-materials open http://127.0.0.1:4182/Tools/design/go-materials.html
npx --package @playwright/cli playwright-cli -s=go-materials run-code --filename Tools/design/export-go-materials.js
```

The export driver is a Playwright function expression: retain its form without a trailing semicolon.

`Assets/Font/DoraUISans-Regular.otf` and `DoraUISans-Medium.otf` derive from [Noto Sans CJK SC](https://github.com/notofonts/noto-cjk/tree/main/Sans/OTF/SimplifiedChinese). `prepare-go-font.py` accepts either weight, normalizes the hhea line box to its existing typographic metrics and renames the derived face. Glyph outlines and Unicode coverage are retained. The SIL Open Font License is bundled beside the fonts. Body copy uses Regular; main titles use Medium. Source editing and code blocks retain Sarasa Mono. Each full CJK face is approximately 16 MB.
