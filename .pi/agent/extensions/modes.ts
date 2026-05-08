 import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

   export default function modes(pi: ExtensionAPI) {
     let mode: "plan" | "build" = "build";

     const applyMode = () => {
       pi.setActiveTools(
         mode === "plan"
           ? ["read", "bash", "grep", "find", "ls"] // no edit/write
           : ["read", "bash", "edit", "write"]
       );
     };

     const setMode = (next: "plan" | "build", ctx?: any) => {
       mode = next;
       applyMode();
       ctx?.ui.notify(`Mode: ${mode}`, "info");
     };

     const thinkingLevels = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;

     const cycleThinkingLevel = (ctx?: any) => {
       const current = pi.getThinkingLevel();
       const index = thinkingLevels.indexOf(current as (typeof thinkingLevels)[number]);
       const next = thinkingLevels[(index + 1) % thinkingLevels.length];
       pi.setThinkingLevel(next);
       ctx?.ui.notify(`Thinking: ${next}`, "info");
     };

     pi.registerFlag("plan", {
       description: "Start in plan mode",
       type: "boolean",
       default: false,
     });

     pi.registerCommand("plan", {
       description: "Switch to plan mode",
       handler: async (_args, ctx) => setMode("plan", ctx),
     });

     pi.registerCommand("build", {
       description: "Switch to build mode",
       handler: async (_args, ctx) => setMode("build", ctx),
     });

     pi.registerShortcut("ctrl+alt+p", {
       description: "Switch to plan mode",
       handler: async (ctx) => setMode("plan", ctx),
     });

     pi.registerShortcut("ctrl+alt+b", {
       description: "Switch to build mode",
       handler: async (ctx) => setMode("build", ctx),
     });

     pi.registerShortcut("ctrl+alt+t", {
       description: "Cycle thinking level",
       handler: async (ctx) => cycleThinkingLevel(ctx),
     });

     pi.on("before_agent_start", async (event) => {
       const extra =
         mode === "plan"
           ? `PLAN MODE:\n- Analyze only\n- Do not modify files\n- Return numbered plan`
           : `BUILD MODE:\n- Implement approved plan\n- Make minimal edits\n- Validate
 changes`;
       return { systemPrompt: `${event.systemPrompt}\n\n${extra}` };
     });

     pi.on("session_start", async (_event, ctx) => {
       if (pi.getFlag("plan") === true) mode = "plan";
       applyMode();
       ctx.ui.notify(`Mode: ${mode}`, "info");
     });
   }
