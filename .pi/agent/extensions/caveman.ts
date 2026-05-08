import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

type CavemanLevel = "off" | "lite" | "full" | "ultra";

const LEVELS: CavemanLevel[] = ["off", "lite", "full", "ultra"];

function normalizeLevel(input: string): CavemanLevel | undefined {
	const value = input.trim().toLowerCase();
	return LEVELS.includes(value as CavemanLevel) ? (value as CavemanLevel) : undefined;
}

function cavemanInstructions(level: CavemanLevel): string | undefined {
	switch (level) {
		case "lite":
			return `CAVEMAN LITE MODE:
- Be concise, direct, professional.
- Drop greetings, filler, apologies, recap unless requested.
- Keep normal grammar.
- Preserve technical accuracy and important caveats.
- Prefer short bullets and code over prose.`;
		case "full":
			return `CAVEMAN FULL MODE:
- Few words. No filler. Fragment okay.
- Technical accuracy stay full.
- Answer first. Explain only needed.
- Prefer code, commands, paths, diffs over prose.
- For code tasks: cause, fix, validate.
- Keep exact code, commands, paths, identifiers unchanged.`;
		case "ultra":
			return `CAVEMAN ULTRA MODE:
- Maximum compression. Telegraphic.
- No greetings, no recap, no hedging.
- Output only essential facts/actions.
- Keep exact code, commands, paths, identifiers unchanged.
- If risks exist, name them in shortest possible form.`;
		case "off":
			return undefined;
	}
}

export default function caveman(pi: ExtensionAPI): void {
	let level: CavemanLevel = "off";

	pi.registerFlag("caveman", {
		description: "Start in caveman terse-output mode",
		type: "boolean",
		default: false,
	});

	function updateStatus(ctx: ExtensionContext): void {
		if (level === "off") {
			ctx.ui.setStatus("caveman", undefined);
			return;
		}
		ctx.ui.setStatus("caveman", ctx.ui.theme.fg("accent", `🪨 ${level}`));
	}

	function setLevel(next: CavemanLevel, ctx: ExtensionContext): void {
		level = next;
		updateStatus(ctx);
		ctx.ui.notify(`Caveman mode: ${level}`, "info");
	}

	function tersePrefix(): string {
		return level === "off" ? "Use caveman full style for this response. " : "";
	}

	pi.registerCommand("caveman", {
		description: "Toggle terse mode or set level: off|lite|full|ultra",
		handler: async (args, ctx) => {
			const requested = normalizeLevel(args);
			if (requested) {
				setLevel(requested, ctx);
				return;
			}

			if (args.trim()) {
				ctx.ui.notify("Usage: /caveman [off|lite|full|ultra]", "warning");
				return;
			}

			setLevel(level === "off" ? "full" : "off", ctx);
		},
	});

	pi.registerCommand("caveman-help", {
		description: "Show caveman commands",
		handler: async (_args, ctx) => {
			ctx.ui.notify(
				`/caveman            toggle full/off
/caveman lite       concise, normal grammar
/caveman full       terse fragments
/caveman ultra      maximum compression
/caveman off        disable
/caveman-commit     generate terse conventional commit from git diff
/caveman-review     one-line findings for current changes
/caveman-compress <file>  compress markdown/memory file`,
				"info",
			);
		},
	});

	pi.registerCommand("caveman-commit", {
		description: "Generate terse conventional commit message from git diff",
		handler: async (args) => {
			const scope = args.trim() || "staged changes if any, otherwise unstaged changes";
			pi.sendUserMessage(`${tersePrefix()}Generate a commit message for ${scope}.

Rules:
- Inspect git diff --cached first; if empty inspect git diff.
- Conventional Commits format.
- Subject <= 50 chars.
- Prefer why over what.
- Output only commit message: subject plus optional body bullets.`);
		},
	});

	pi.registerCommand("caveman-review", {
		description: "Review current changes with one-line findings",
		handler: async (args) => {
			const target = args.trim() || "current git changes";
			pi.sendUserMessage(`${tersePrefix()}Review ${target}.

Rules:
- Inspect relevant diff/files.
- Findings only. No praise. No summary unless no issues.
- One line per finding: path:line: severity: issue. fix.
- Severity: 🔴 bug/security, 🟡 risk, 🔵 style/maintainability.
- If clean, output: No findings.`);
		},
	});

	pi.registerCommand("caveman-compress", {
		description: "Compress a markdown/memory file while preserving code, URLs, paths",
		handler: async (args, ctx) => {
			const file = args.trim();
			if (!file) {
				ctx.ui.notify("Usage: /caveman-compress <file>", "warning");
				return;
			}

			pi.sendUserMessage(`${tersePrefix()}Compress ${file}.

Rules:
- Read file first.
- Preserve code blocks, inline code, URLs, paths, commands, identifiers byte-for-byte.
- Remove filler, duplicate wording, weak advice.
- Keep technical meaning.
- Make backup as ${file}.original.md before writing.
- Then rewrite ${file} with compressed version.
- End with original/compressed rough line counts and percent shorter.`);
		},
	});

	pi.on("before_agent_start", async (event) => {
		const extra = cavemanInstructions(level);
		if (!extra) return;
		return { systemPrompt: `${event.systemPrompt}\n\n${extra}` };
	});

	pi.on("session_start", async (_event, ctx) => {
		if (pi.getFlag("caveman") === true) {
			level = "full";
		}
		updateStatus(ctx);
	});
}
