"""ledger: append one finished Faz B step to b_taslak/R_DEFTER.md and write its commit message/file list.

Usage: python -I ledger.py <workflow output json> <step> [commit hash]
Without a hash: writes <SP>/<step>_msg.txt and <step>_files.txt and prints the review summary.
With a hash: appends the step's acceptance, pending items and risks to R_DEFTER.md.
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
SP = os.path.dirname(os.path.abspath(__file__))
DEFTER = r"C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/b_taslak/R_DEFTER.md"

out, step = sys.argv[1], sys.argv[2]
commit = sys.argv[3] if len(sys.argv) > 3 else ""
d = json.load(open(out, encoding="utf-8"))["result"]
if "code" not in d and step in d:  # faz_b_chain.js returns one result per step
    d = d[step]
code, gates, review, regate = d.get("code") or {}, d.get("gates") or {}, d.get("review") or {}, d.get("regate")

if not commit:
    print("CODE", code.get("status"), code.get("blocked_reason", ""))
    print("GATES all_green=", gates.get("all_green"))
    for r in gates.get("results", []):
        print("  ", "PASS" if r["pass"] else "FAIL", r["cmd"][:100], "|", r["evidence"][:160].replace("\n", " "))
    print("PARITY", gates.get("byte_parity"))
    for s in gates.get("shots", []):
        print("  SHOT", s["png"][-70:], "|", s["note_tr"][:140])
    print("REVIEW", review.get("verdict"), "changed_code=", review.get("changed_code"), "rerun=", review.get("rerun"))
    print("BLOCK", review.get("block_reason_tr", ""))
    print("FIXES", (review.get("fixes_tr") or "")[:1500])
    if regate:
        print("REGATE all_green=", regate.get("all_green"))
        for r in regate.get("results", []):
            print("  ", "PASS" if r["pass"] else "FAIL", r["cmd"][:100], "|", r["evidence"][:160].replace("\n", " "))
    print("FILES", len(review.get("files_to_commit") or []))
    print("MSG", (review.get("commit_message") or "").split("\n")[0])
    open(os.path.join(SP, f"{step}_msg.txt"), "w", encoding="utf-8", newline="\n").write(
        (review.get("commit_message") or "").rstrip() + "\n")
    open(os.path.join(SP, f"{step}_files.txt"), "w", encoding="utf-8", newline="\n").write(
        "\n".join(review.get("files_to_commit") or []) + "\n")
    sys.exit(0)

new = not os.path.exists(DEFTER)
with open(DEFTER, "a", encoding="utf-8", newline="\n") as f:
    if new:
        f.write("# Faz B adım defteri (R'nin girdisi; commit'lenmez)\n")
    f.write(f"\n## {step} · `{commit}`\n")
    f.write(f"**Başlık:** {(review.get('commit_message') or '').splitlines()[0]}\n\n")
    f.write("### Kabul\n" + (review.get("acceptance_tr") or "") + "\n\n")
    f.write("### Onay bekleyen\n" + (review.get("pending_tr") or "") + "\n\n")
    f.write("### Sabitler (kod ajanı)\n" + "\n".join(f"- {c}" for c in code.get("pending_constants") or []) + "\n\n")
    f.write("### Metinler (kod ajanı)\n" + "\n".join(f"- {c}" for c in code.get("pending_texts") or []) + "\n\n")
    f.write("### Riskler\n" + (code.get("risks_tr") or "") + "\n\n")
    f.write("### İnceleme düzeltmeleri\n" + (review.get("fixes_tr") or "") + "\n")
print("ledger appended", step, commit)
