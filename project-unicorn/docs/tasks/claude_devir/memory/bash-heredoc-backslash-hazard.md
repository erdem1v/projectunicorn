---
name: bash-heredoc-backslash-hazard
description: Bash tool mangles backslashes in heredocs — GDScript line continuations arrive as literal backslash-n; write patch scripts to a file instead
metadata: 
  node_type: memory
  type: reference
  originSessionId: d1c4e074-d2f5-43b6-a4d0-15191be8fbc3
  modified: 2026-08-27T09:43:06.973Z
---

**The Bash tool's wrapper collapses backslash escapes inside heredocs**, even quoted ones
(`<<'PYEOF'`). A Python patch string meaning `\` + newline — GDScript's line continuation —
arrives in the file as a literal backslash followed by the letter `n`, on one line.

Godot reports it as: `Parse Error: Expected new line after "\"`.

It is invisible in `grep` and in `sed -n 'Np'` output, because the terminal renders `\n` as two
characters on the same line and nothing looks obviously wrong. `od -c` is what proves it:
`\` and `n` show as two separate bytes.

A second, related failure: a command containing backticks inside a heredoc can make the whole
Bash invocation die with ``unexpected EOF while looking for matching `'`` — the heredoc body is
being parsed when it should be literal.

**How to apply:**
- For any patch containing a backslash, a backtick, or more than ~30 lines of code, use the
  **Write tool** to put the script in the scratchpad and then run it with
  `python <path>`. Write does not go through the shell.
- Short heredocs are fine as long as they contain no `\` and no backticks.
- After a patch run, sweep for the damage:
  `python -c "..."` looking for `chr(92)+'n'` in non-comment lines of the touched files.
- Same class of bug, different cause: `s.count(old) == 1` can pass while matching at the WRONG
  indentation, because a 1-tab anchor is a substring of a 2-tab line. The replacement then lands
  at the wrong depth ("Expected statement, found Indent"). Anchor on whole lines including their
  full leading tabs, and verify with `sed -n 'A,Bp' file | cat -A`.

Related: [[strings-csv-surgery]], [[smoke-verification-cadence]]
