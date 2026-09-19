#!/usr/bin/env node
// Uses the same TypeScript-to-Lua compiler as the Web IDE. Run with --write to
// regenerate native modules; without it, checks that committed Lua matches TSX.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const assert = require('node:assert/strict');
const Module = require('node:module');
const root = path.resolve(__dirname, '../..');
const web = path.join(root, 'Tools/dora-dora');
process.env.NODE_PATH = path.join(web, 'node_modules');
Module._initPaths();
const ts = require('typescript');
const esbuild = require('esbuild');
const mobile = path.join(root, 'Assets/Script/Dev/Mobile');
const modules = ['Description.tsx', 'Motion.ts', 'Theme.ts', 'Visual.tsx', 'Controls.tsx', 'Cartridge.tsx',
  'GestureGuide.ts', 'FeedModel.ts', 'Feed.tsx', 'ProjectPresentation.ts',
  'WorkspacePanel.tsx', 'Remix.tsx', 'RemixTranscript.ts', 'TextInput.ts',
  'LLMSetup.tsx', 'PackagePanel.tsx', 'ProjectIndex.tsx'];

function loadModel(name) {
  const output = esbuild.buildSync({entryPoints: [path.join(mobile, name)],
    bundle: true, platform: 'node', format: 'cjs', write: false});
  const module = {exports: {}};
  new Function('math', 'module', output.outputFiles[0].text)(Math, module);
  return module.exports;
}
const model = loadModel('FeedModel.ts');
assert.equal(model.nextFeedIndex(4, 4, 'discover'), 0);
assert.equal(model.nextFeedIndex(-1, 4, 'discover'), 3);
assert.equal(model.nextFeedIndex(4, 4, 'local'), 3);
assert.equal(model.nextFeedIndex(-1, 4, 'local'), 0);
assert.equal(model.nextFeedIndex(20, 0, 'discover'), 0);
assert.deepEqual(model.visibleFeedPages(0, 0, 'discover'), []);
assert.deepEqual(model.visibleFeedPages(0, 3, 'discover'),
  [{index: 2, offset: -1}, {index: 0, offset: 0}, {index: 1, offset: 1}]);
assert.deepEqual(model.visibleFeedPages(2, 3, 'local'),
  [{index: 1, offset: -1}, {index: 2, offset: 0}]);
assert.equal(model.visibleFeedPages(0, 1, 'discover').length, 3);
assert.equal(model.resolveFeedGesture(-100, 8, 390, 844), 'play');
assert.equal(model.resolveFeedGesture(100, 8, 390, 844), 'none');
assert.equal(model.resolveFeedGesture(8, 150, 390, 844), 'next');
assert.equal(model.resolveFeedGesture(8, -150, 390, 844), 'previous');
assert.equal(model.resolveFeedGesture(-100, 0, 390, 844, true), 'none');
assert.equal(model.resolveFeedGesture(-20, 0, 390, 844), 'none');
assert.equal(model.resolveFeedGesture(-50, 0, 390, 844, false, -0.7), 'play');
assert.equal(model.resolveFeedGesture(-50, 0, 390, 844, false, -0.2), 'none');
assert.equal(model.resolveFeedGesture(50, 0, 390, 844, false, 0.7), 'none');
assert.equal(model.resolveFeedGesture(-20, 0, 390, 844, false, -1), 'none');
assert.equal(model.resolveFeedGesture(-50, 0, 390, 844, true, -0.7), 'none');
const remix = loadModel('RemixModel.ts');
assert.equal(remix.canLeaveRemix('RUNNING'), false);
assert.equal(remix.canLeaveRemix('WAITING_USER'), false);
assert.equal(remix.canLeaveRemix('STOPPED'), true);
assert.equal(remix.resolveRemixWorkMode({kind: 'main', workMode: 'plan'}), 'plan');
assert.equal(remix.resolveRemixWorkMode({kind: 'sub', workMode: 'plan'}), 'code');
console.log('Go navigation and session-state assertions passed.');

const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'dora-go-ui-'));
try {
  const compiler = path.join(temp, 'tstl.cjs');
  esbuild.buildSync({entryPoints: [path.join(web, 'src/3rdParty/tstl/index.ts')],
    outfile: compiler, bundle: true, platform: 'node', format: 'cjs', external: ['typescript'], logLevel: 'silent'});
  const tstl = require(compiler);
  const roots = fs.readdirSync(mobile).filter(f => /\.tsx?$/.test(f)).map(f => path.join(mobile, f));
  const declarations = [];
  function walk(dir) {
    for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
      const file = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(file);
      else if (file.endsWith('.d.ts')) declarations.push(file);
    }
  }
  walk(path.join(root, 'Assets/Script/Lib/Dora/en'));
  walk(path.join(root, 'Assets/Script/Lib/UI'));
  const program = ts.createProgram([...roots, ...declarations], {
    strict: true, noUnusedLocals: true, skipLibCheck: true, jsx: ts.JsxEmit.React,
    luaTarget: tstl.LuaTarget.Lua55, luaLibImport: tstl.LuaLibImportKind.Require,
    noHeader: true, noImplicitSelf: true, moduleResolution: ts.ModuleResolutionKind.Classic,
    target: ts.ScriptTarget.ESNext, module: ts.ModuleKind.ESNext,
    baseUrl: path.join(root, 'Assets/Script'), paths: {'*': ['*', 'Lib/*']},
  });
  // Do not run dependency-resolution emit: Dora/nvg are native modules.
  const result = tstl.getProgramTranspileResult(ts.sys, () => {}, {program,
    sourceFiles: modules.map(file => program.getSourceFile(path.join(mobile, file)))});
  const diagnostics = [...ts.getPreEmitDiagnostics(program), ...result.diagnostics]
    .filter(d => !d.file || /[\\/]Dev[\\/]Mobile[\\/]/.test(d.file.fileName));
  if (diagnostics.length) console.log(ts.formatDiagnosticsWithColorAndContext(diagnostics,
    {getCanonicalFileName: f => f, getCurrentDirectory: () => root, getNewLine: () => '\n'}));
  assert(!diagnostics.some(d => d.category === ts.DiagnosticCategory.Error), 'Mobile TypeScript compilation failed');
  for (const file of result.transpiledFiles) {
    const target = file.fileName.replace(/\.tsx?$/, '.lua');
    if (process.argv.includes('--write')) fs.writeFileSync(target, file.code);
    else assert.equal(fs.readFileSync(target, 'utf8').replace(/\r\n/g, '\n'), file.code.replace(/\r\n/g, '\n'),
      `Stale Lua: ${target}; rerun with --write`);
  }
  console.log(`${result.transpiledFiles.length} native Lua modules ${process.argv.includes('--write') ? 'generated' : 'verified'}.`);
} finally {
  fs.rmSync(temp, {recursive: true, force: true});
}
