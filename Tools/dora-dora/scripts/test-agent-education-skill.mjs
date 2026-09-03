import assert from "node:assert/strict";
import { access, readFile, readdir } from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const skillRelativeRoot = "Assets/Doc/skills/creating-educational-interactives";
const skillRoot = path.join(repoRoot, skillRelativeRoot);
const builtInSkillLinkPrefix = "@agent-skill/builtin/creating-educational-interactives/";

const subjects = [
	"art.md",
	"biology.md",
	"chemistry.md",
	"chinese-language-literature.md",
	"civics-politics-ethics.md",
	"english-language.md",
	"geography.md",
	"history.md",
	"information-technology-programming.md",
	"interdisciplinary.md",
	"mathematics.md",
	"music.md",
	"physical-education-health.md",
	"physics.md",
	"primary-science.md",
	"technology-engineering.md",
];

const patterns = [
	"assessment-feedback.md",
	"block-programming.md",
	"creation-studio.md",
	"dialogue-roleplay.md",
	"evidence-analysis.md",
	"inquiry-learning.md",
	"interactive-visualization.md",
	"map-timeline-exploration.md",
	"narrative-avg.md",
	"system-simulation.md",
	"teacher-orchestration.md",
	"virtual-lab.md",
];

const requiredFiles = [
	"SKILL.md",
	"references/generation-contract.md",
	"references/pedagogy.md",
	"references/subject-router.md",
	"tests/scenarios.md",
	...subjects.map(name => `references/subjects/${name}`),
	...patterns.map(name => `patterns/${name}`),
];

const readSkillFile = relativePath => readFile(path.join(skillRoot, relativePath), "utf8");

for (const relativePath of requiredFiles) {
	await access(path.join(skillRoot, relativePath));
}

const skill = await readSkillFile("SKILL.md");
const frontmatter = skill.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
assert.ok(frontmatter, "education skill must have YAML frontmatter");
assert.match(frontmatter[1], /^name:\s*creating-educational-interactives\s*$/m);
assert.match(frontmatter[1], /^description:\s*Use when .+$/m);
const description = frontmatter[1].match(/^description:\s*(.+)$/m)?.[1].trim() ?? "";
assert.ok(description.length <= 500, "education skill description must stay within 500 characters");
assert.match(frontmatter[1], /^always:\s*true\s*$/m,
	"the education variant must inject its educational contract into every Agent role");
assert.match(skill, /the interaction itself must be the learning action/i);
assert.match(skill, /## Teacher Mode/);
assert.match(skill, /## Student Mode/);
assert.match(skill, /references\/subject-router\.md/);
assert.match(skill, /references\/generation-contract\.md/);

const markdownFiles = [];
async function collectMarkdownFiles(directory) {
	for (const entry of await readdir(directory, { withFileTypes: true })) {
		const fullPath = path.join(directory, entry.name);
		if (entry.isDirectory()) {
			await collectMarkdownFiles(fullPath);
		} else if (entry.isFile() && entry.name.endsWith(".md")) {
			markdownFiles.push(fullPath);
		}
	}
}

await collectMarkdownFiles(skillRoot);
const markdownInventory = markdownFiles
	.map(markdownPath => path.relative(skillRoot, markdownPath).split(path.sep).join("/"))
	.sort();
assert.deepEqual(markdownInventory, [...requiredFiles].sort(),
	"the education-skill manifest must enumerate every Markdown file exactly once");
const linkedMarkdownFiles = new Map();
const nonCanonicalSkillLinks = [];
let internalSkillLinkCount = 0;
for (const markdownPath of markdownFiles) {
	const content = await readFile(markdownPath, "utf8");
	const sourceRelativePath = path.relative(skillRoot, markdownPath).split(path.sep).join("/");
	assert.ok(content.trim() !== "", `${sourceRelativePath} must not be empty`);
	const targets = [];
	for (const match of content.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)) {
		const link = match[1];
		if (link.includes("://") || link.startsWith("#")) {
			continue;
		}
		internalSkillLinkCount += 1;
		if (!link.startsWith(builtInSkillLinkPrefix)) {
			nonCanonicalSkillLinks.push(`${sourceRelativePath}: ${link}`);
		}
		const linkedPath = link.startsWith("@agent-skill/builtin/")
			? path.resolve(repoRoot, "Assets/Doc/skills", link.slice("@agent-skill/builtin/".length).split("#", 1)[0])
			: path.resolve(path.dirname(markdownPath), link.split("#", 1)[0]);
		assert.ok(linkedPath.startsWith(path.join(repoRoot, "Assets/Doc/skills") + path.sep),
			`${path.relative(skillRoot, markdownPath)} link escapes the built-in skill root: ${link}`);
		await access(linkedPath);
		if (linkedPath.endsWith(".md") && linkedPath.startsWith(skillRoot + path.sep)) {
			targets.push(linkedPath);
		}
	}
	linkedMarkdownFiles.set(markdownPath, targets);
}

assert.deepEqual(nonCanonicalSkillLinks, [],
	"every internal education-skill link must be directly readable through @agent-skill/builtin");

const reachableMarkdownFiles = new Set();
const pendingMarkdownFiles = [path.join(skillRoot, "SKILL.md")];
while (pendingMarkdownFiles.length > 0) {
	const current = pendingMarkdownFiles.pop();
	if (!current || reachableMarkdownFiles.has(current)) {
		continue;
	}
	reachableMarkdownFiles.add(current);
	for (const target of linkedMarkdownFiles.get(current) ?? []) {
		pendingMarkdownFiles.push(target);
	}
}

const unreachableMarkdownFiles = markdownFiles
	.filter(markdownPath => !reachableMarkdownFiles.has(markdownPath))
	.map(markdownPath => path.relative(skillRoot, markdownPath).split(path.sep).join("/"))
	.sort();
assert.deepEqual(unreachableMarkdownFiles, [],
	"every education-skill Markdown file must be reachable from SKILL.md");

const [skillsTs, skillsLua, workspaceTs, workspaceLua] = await Promise.all([
	readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Skills.ts"), "utf8"),
	readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Skills.lua"), "utf8"),
	readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Tool/Workspace.ts"), "utf8"),
	readFile(path.join(repoRoot, "Assets/Script/Lib/Agent/Tool/Workspace.lua"), "utf8"),
]);
assert.match(skillsTs, /getAlwaysSkills\(\)/);
assert.match(skillsTs, /buildActiveSkillsContent\(\)/);
assert.match(skillsTs, /parts\.push\(`\\n\$\{skill\.body\}`\)/,
	"authored loader must inject the full body of always-on skills");
assert.match(skillsLua, /getAlwaysSkills/);
assert.match(skillsLua, /buildActiveSkillsContent/);
assert.match(skillsLua, /skill\.body/,
	"runtime Lua loader must inject the full body of always-on skills");
assert.match(workspaceTs, /function resolveAgentSkillFilePath/);
assert.match(workspaceTs, /namespaced\.startsWith\("builtin\/"\)/);
assert.match(workspaceTs, /Path\(Content\.assetPath, "Doc", "skills"\)/,
	"authored read_file resolver must map built-in skill paths into Assets/Doc/skills");
assert.match(workspaceLua, /resolveAgentSkillFilePath/);
assert.match(workspaceLua, /__TS__StringStartsWith\(namespaced, "builtin\/"\)/);
assert.match(workspaceLua, /Path\(Content\.assetPath, "Doc", "skills"\)/,
	"runtime Lua read_file resolver must map built-in skill paths into Assets/Doc/skills");

console.log(
	`education skill integration checks passed (${requiredFiles.length} required files, `
	+ `${reachableMarkdownFiles.size} reachable Markdown files, ${internalSkillLinkCount} canonical internal links)`,
);
