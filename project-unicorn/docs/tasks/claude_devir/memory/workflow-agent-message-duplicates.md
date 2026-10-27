---
name: workflow-agent-message-duplicates
description: SendMessage to an agent running inside a Workflow resumes a second copy of it (two agents in one working copy); add scope by stopping/relaunching instead
metadata:
  node_type: memory
  type: feedback
  originSessionId: eeffbe9c-d5c1-4a8e-8ce4-9e4b60603345
  modified: 2026-10-27T10:45:38.188Z
---

2026-10-27 (OLAYLAR 7b): I sent extra work to the workflow's running kod agent with `SendMessage` (to its agentId from journal.jsonl). The tool answered "Resuming agent …" and started a resumed copy from the transcript while the workflow's own agent kept running. Two agents then edited the same scratchpad copy; one noticed and warned. Fix was TaskStop on the workflow and handing everything to the listed copy, then running review/shots as a separate workflow.

**Why:** workflow agents are not tracked as in-process agents, so a message to their id is treated as "resume a finished agent", not "deliver to a running one".

**How to apply:** never message an agent inside a running Workflow. To add scope mid-run: TaskStop the workflow, then either relaunch with an edited script (resume caches unchanged agents) or let the stage finish and add the item to the next stage's prompt. After TaskStop, check `ps` for orphan Godot processes ([[taskstop-orphan-child]]) and the locks.
