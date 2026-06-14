const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const folderName = "Projet de vie (maisons de memoire)";
const count = 74;

function escApple(value) {
  return String(value).replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function getNote(index) {
  const script = [
    'tell application "/System/Applications/Notes.app"',
    `set targetFolder to first folder whose name is "${escApple(folderName)}"`,
    `set n to item ${index + 1} of notes of targetFolder`,
    "return name of n & tab & (creation date of n as text) & tab & (modification date of n as text) & tab & body of n",
    "end tell",
  ];

  const raw = execFileSync(
    "osascript",
    script.flatMap((line) => ["-e", line]),
    { encoding: "utf8", maxBuffer: 10 * 1024 * 1024, timeout: 7000 },
  );
  const parts = raw.replace(/\n$/, "").split("\t");
  return {
    ordinal: index + 1,
    name: parts[0] || "",
    creationDate: parts[1] || "",
    modificationDate: parts[2] || "",
    body: parts.slice(3).join("\t") || "",
  };
}

function decodeEntities(value) {
  const named = { amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " " };
  return (value || "").replace(/&(#x?[0-9a-fA-F]+|[a-zA-Z]+);/g, (match, entity) => {
    if (entity[0] === "#") {
      const hex = entity[1]?.toLowerCase() === "x";
      const code = parseInt(entity.slice(hex ? 2 : 1), hex ? 16 : 10);
      return Number.isFinite(code) ? String.fromCodePoint(code) : match;
    }
    return Object.prototype.hasOwnProperty.call(named, entity) ? named[entity] : match;
  });
}

function htmlToMarkdown(html) {
  let text = html || "";
  text = text
    .replace(/\r/g, "")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n\n")
    .replace(/<\/div>/gi, "\n")
    .replace(/<\/h[1-6]>/gi, "\n\n")
    .replace(/<li[^>]*>/gi, "- ")
    .replace(/<\/li>/gi, "\n")
    .replace(/<[^>]+>/g, "");
  text = decodeEntities(text);
  text = text
    .split("\n")
    .map((line) => line.replace(/[ \t]+$/g, ""))
    .join("\n");
  return text.replace(/\n{3,}/g, "\n\n").trim();
}

function formatDate(value) {
  if (!value) return "unknown";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toISOString().slice(0, 10);
}

const notes = [];
const skipped = [];

for (let index = 0; index < count; index += 1) {
  try {
    notes.push(getNote(index));
  } catch (error) {
    skipped.push({
      ordinal: index + 1,
      reason: String(error.message || error).split("\n")[0].slice(0, 180),
    });
  }
}

const lines = [];
lines.push(
  `# Apple Notes Context: ${folderName}`,
  "",
  `Exported: ${new Date().toISOString().slice(0, 10)}`,
  `Notes exported: ${notes.length}`,
  `Notes skipped: ${skipped.length}`,
  `Source: Apple Notes folder \`${folderName}\`.`,
);

if (skipped.length) {
  lines.push("", "## Skipped Notes");
  for (const skippedNote of skipped) {
    lines.push(`- Original folder order ${skippedNote.ordinal}: ${skippedNote.reason}`);
  }
}

lines.push("", "## Index");
notes.forEach((note, index) => {
  lines.push(
    `${index + 1}. ${note.name || "(Untitled)"} (${formatDate(note.creationDate)} -> ${formatDate(
      note.modificationDate,
    )})`,
  );
});

lines.push("", "## Notes");
for (const [index, note] of notes.entries()) {
  lines.push(
    "",
    `### ${index + 1}. ${note.name || "(Untitled)"}`,
    "",
    `- Created: ${formatDate(note.creationDate)}`,
    `- Modified: ${formatDate(note.modificationDate)}`,
    `- Original folder order: ${note.ordinal}`,
    "",
    htmlToMarkdown(note.body) || "_No text content exported._",
  );
}
lines.push("");

const outPath = path.join(process.cwd(), "apple-notes-project-context.md");
fs.writeFileSync(outPath, lines.join("\n"), "utf8");

console.log(JSON.stringify({ outPath, total: count, exported: notes.length, skipped }, null, 2));
