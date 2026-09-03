import { createReadStream } from "node:fs";
import { createServer } from "node:http";
import { fileURLToPath } from "node:url";

const host = "127.0.0.1";
const port = 8870;
const indexPath = fileURLToPath(new URL("./index.html", import.meta.url));

const server = createServer((request, response) => {
	if ((request.method !== "GET" && request.method !== "HEAD") || request.url !== "/") {
		response.writeHead(404).end();
		return;
	}

	response.writeHead(200, {
		"Cache-Control": "no-store",
		"Content-Type": "text/html; charset=utf-8",
	});
	if (request.method === "HEAD") {
		response.end();
		return;
	}
	createReadStream(indexPath).pipe(response);
});

server.on("error", (error) => {
	console.error(`Unable to serve Dora EDU launch test page: ${error.message}`);
	process.exitCode = 1;
});

server.listen(port, host, () => {
	console.log(`Dora EDU launch test page: http://${host}:${port}/`);
});
