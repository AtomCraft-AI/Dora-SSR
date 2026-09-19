// Serve the repository at 127.0.0.1:4182, then run with playwright-cli run-code --filename.
async (page) => {
	const context = await page
		.context()
		.browser()
		.newContext({ viewport: { width: 284, height: 356 }, deviceScaleFactor: 3 });
	const p = await context.newPage();
	const base = "http://127.0.0.1:4182/Tools/design/go-materials.html";
	for (const [kind, width, height] of [
		["cartridge", 284, 356],
		["console", 210, 328],
	]) {
		await p.setViewportSize({ width, height });
		await p.goto(base + "?kind=" + kind);
		await p.locator("img").evaluateAll((images) => Promise.all(images.map((img) => img.decode())));
		await p.screenshot({ path: "Assets/Image/GoUI/" + (width === 24 ? "icon-" : "") + kind + ".png", omitBackground: true });
	}
	await context.close();
	return "Exported native Go materials at 3x.";
}