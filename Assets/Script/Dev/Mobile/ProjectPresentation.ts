import { DB } from "Dora";
export function projectDisplayName(workDir: string | undefined, fallback: string) {
	if (!workDir) return fallback;
	const rows = DB.query("select value_str from Config where name = ? limit 1", ["goProjectTitle:" + workDir]) as unknown[][] | undefined;
	return rows && rows.length > 0 && typeof rows[0][0] === "string" ? (rows[0][0] as string) : fallback;
}
export function saveProjectDisplayName(workDir: string, title: string) {
	return DB.exec("insert or replace into Config(name,value_str) values(?,?)", ["goProjectTitle:" + workDir, title]) >= 0;
}
