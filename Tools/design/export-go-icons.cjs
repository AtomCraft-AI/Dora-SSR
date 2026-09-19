// Lucide stays a build dependency; Dora loads only these small, tintable textures.
const fs = require('node:fs');
const path = require('node:path');
const { Resvg } = require('@resvg/resvg-js');
const source = path.dirname(require.resolve('lucide-static/package.json'));
const output = path.resolve(__dirname, '../../Assets/Image/GoUI');
const icons = {
  settings: 'settings', back: 'chevron-left', more: 'ellipsis', down: 'arrow-down',
  exit: 'log-out', plus: 'plus', code: 'code-xml', remix: 'git-fork',
  files: 'folder', changes: 'git-compare-arrows', logs: 'terminal',
  swap: 'arrow-right-left', close: 'x', next: 'chevron-right', up: 'arrow-up',
  stop: 'square', dropdown: 'chevron-down', circle: 'circle', checked: 'circle-check', edit: 'pencil', check: 'check'
};
fs.mkdirSync(output, {recursive: true});
for (const [name, upstream] of Object.entries(icons)) {
  const svg = fs.readFileSync(path.join(source, 'icons', upstream + '.svg'), 'utf8')
    .replace(/currentColor/g, '#ffffff').replace('stroke-width="2"', 'stroke-width="1.7"');
  fs.writeFileSync(path.join(output, `icon-${name}.png`), new Resvg(svg, {
    fitTo: {mode: 'width', value: 72}
  }).render().asPng());
}
fs.copyFileSync(path.join(source, 'LICENSE'), path.join(output, 'Lucide-LICENSE.txt'));
fs.writeFileSync(path.join(output, 'icons.json'), JSON.stringify({
  source: 'https://lucide.dev', version: require('lucide-static/package.json').version,
  size: 72, strokeWidth: 1.7, icons
}, null, 2) + '\n');
console.log(`Exported ${Object.keys(icons).length} Lucide icons at 3x.`);
