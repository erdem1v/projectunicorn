#!/usr/bin/env python
"""Generate docs/EVENT_SIGNAL_MANIFEST.md from source. Run from the project root.

    python tools/gen_signal_manifest.py

GDD OLAY MOTORU rev 2 §15.1 wants a static manifest: which system emits what, who
listens, what the payload is. Hand-keeping that guarantees drift, so it is generated,
like docs/content/events_draft/_vocabulary.md.

The scan is textual on purpose: `EventBus.<name>.emit` / `.connect` is the only shape
the codebase uses, and a parser would buy nothing a grep does not already give.
"""
import os
import re
import sys
import json
import collections
import datetime

sys.stdout.reconfigure(encoding='utf-8')

BUS = 'scripts/autoload/event_bus.gd'
BINDINGS = 'scripts/events/core/signals.gd'
CATALOG = 'scripts/events/catalog/catalog.gd'
ROOT = 'scripts'
OUT = 'docs/EVENT_SIGNAL_MANIFEST.md'


def scan():
    bus_src = open(BUS, encoding='utf-8').read()
    signals, section = [], 'ungrouped'
    for line in bus_src.split('\n'):
        hm = re.match(r'^# --- (.+?) ---\s*$', line)
        if hm:
            section = hm.group(1).strip()
        m = re.match(r'^signal\s+(\w+)\s*(\([^)]*\))?', line)
        if m:
            signals.append((m.group(1), (m.group(2) or '()').strip(), section))

    names = [s[0] for s in signals]
    emits = collections.defaultdict(list)
    conns = collections.defaultdict(list)
    emit_re = {n: re.compile(r'EventBus\.' + n + r'\.emit\b') for n in names}
    conn_re = {n: re.compile(r'EventBus\.' + n + r'\.connect\b') for n in names}

    for root, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for fn in files:
            if not fn.endswith('.gd'):
                continue
            rel = os.path.join(root, fn).replace(os.sep, '/')
            try:
                txt = open(rel, encoding='utf-8').read()
            except OSError:
                continue
            for i, line in enumerate(txt.split('\n'), 1):
                if 'EventBus.' not in line:
                    continue
                for n in names:
                    if emit_re[n].search(line):
                        emits[n].append('%s:%d' % (rel, i))
                    if conn_re[n].search(line):
                        conns[n].append('%s:%d' % (rel, i))
    return signals, emits, conns


def engine_bindings():
    """Signal names a card MAY trigger on (EvSignals.BINDINGS). An allowlist only: a binding
    alone connects nothing."""
    src = open(BINDINGS, encoding='utf-8').read()
    block = re.search(r'^const BINDINGS := \{\n(.*?)^\}', src, re.S | re.M).group(1)
    return re.findall(r'^\s*"(\w+)":', block, re.M)


def _gd_const(src, name):
    m = re.search(r'^const %s := (.+)$' % name, src, re.M)
    return re.findall(r'"([^"]*)"', m.group(1))


def engine_triggers():
    """Signal names the event engine actually connects at runtime: EvSignals.install() connects
    exactly the `trigger.signal` of the loaded cards. The walk mirrors EvCatalog._walk (same
    directory, same excluded directories and filename prefixes, read out of catalog.gd), so a
    card the pool skips does not count as an ear."""
    src = open(CATALOG, encoding='utf-8').read()
    cards_dir = _gd_const(src, 'CARDS_DIR')[0].replace('res://', '').rstrip('/')
    ex_dirs = _gd_const(src, 'EXCLUDED_DIRS')
    ex_prefixes = _gd_const(src, 'EXCLUDED_PREFIXES')
    heard = {}
    for root, dirs, files in os.walk(cards_dir):
        dirs[:] = sorted(d for d in dirs if d not in ex_dirs and not d.startswith('.'))
        for fn in sorted(files):
            if not fn.endswith('.json') or any(fn.startswith(p) for p in ex_prefixes):
                continue
            rel = os.path.join(root, fn).replace(os.sep, '/')
            try:
                with open(rel, encoding='utf-8') as f:
                    card = json.load(f)
            except (OSError, ValueError):
                continue
            trig = card.get('trigger') if isinstance(card, dict) else None
            name = trig.get('signal', '') if isinstance(trig, dict) else ''
            if name:
                heard.setdefault(name, []).append(rel)
    return cards_dir, heard


def owner_of(sites):
    """The module a signal belongs to, read off its emit sites."""
    mods = []
    for s in sites:
        base = s.split(':')[0].split('/')[-1].replace('.gd', '')
        if base not in mods:
            mods.append(base)
    return ' · '.join(mods) if mods else '—'


def fmt(sites, limit=3):
    if not sites:
        return '—'
    shown = ', '.join('`%s`' % s for s in sites[:limit])
    if len(sites) > limit:
        shown += ' +%d' % (len(sites) - limit)
    return shown


def main():
    signals, emits, conns = scan()
    bound = engine_bindings()
    cards_dir, heard = engine_triggers()
    prod = lambda ss: [s for s in ss if '/debug/' not in s]

    no_emit = [n for n, _p, _s in signals if not prod(emits[n])]
    no_listen = [n for n, _p, _s in signals if not prod(conns[n]) and n not in heard]

    L = []
    w = L.append
    w('# EVENT SIGNAL MANIFEST')
    w('')
    w('**GENERATED — do not hand-edit.** Regenerate with `python tools/gen_signal_manifest.py`.')
    w('Source: `%s`, every `.gd` under `%s/`, `EvSignals.BINDINGS` and the card triggers.'
      % (BUS, ROOT))
    w('Last generated %s.' % datetime.date.today().isoformat())
    w('')
    w('Authority: [`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](<../GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md>) §15. The read side of')
    w('the same idea is the seam list in [`content/events_draft/_vocabulary.md`](content/events_draft/_vocabulary.md) §b.')
    w('')
    w('## Why this is generated')
    w('')
    w('§15.1 asks for a static manifest of emitter, listeners and payload. Hand-keeping that')
    w('for %d signals guarantees drift, and drift here is not cosmetic: §15.2 makes "a declared'
      % len(signals))
    w('signal with no emit point" a lint error, so the manifest is the lint rule\'s input.')
    w('')
    w('## Headline numbers')
    w('')
    w('| | count |')
    w('|---|---|')
    w('| Signals declared | **%d** |' % len(signals))
    w('| Declared with **no production emitter** | **%d** |' % len(no_emit))
    w('| Emitted with **no production listener** | **%d** |' % len(no_listen))
    w('')
    w('The second number is the §15.2 violation set. The third is **not** a defect: the Ekip,')
    w('Ürün, Ar-Ge and Satış modules publish their read-surface signals ahead of any consumer,')
    w('so the engine finds a vocabulary rather than having to discover one.')
    w('')
    w('The event engine connects signals by NAME at runtime, which a static scan for `.connect(`')
    w('cannot see. `EvSignals.install()` (`%s`) connects exactly the `trigger.signal` of the'
      % BINDINGS)
    w('cards the catalogue loads from `%s/`, and this generator reads the same cards. Today that'
      % cards_dir)
    w('is %d signal(s): %s. They are listed as `EvSignals (card trigger)` and are not counted'
      % (len(heard), ', '.join('`%s`' % n for n in sorted(heard)) or 'none'))
    w('as unheard.')
    w('')
    w('`EvSignals.BINDINGS` is an allowlist of the %d signals a card MAY trigger on. A binding'
      % len(bound))
    w('alone connects nothing, so the others are listed as `EvSignals (bindable)` and still')
    w('count as unheard.')
    w('')
    w('## §15.2 violations — declared, never emitted')
    w('')
    for n in no_emit:
        params = next(p for nm, p, _s in signals if nm == n)
        dbg = [s for s in emits[n] if '/debug/' in s]
        note = ' Debug-only emit at %s.' % fmt(dbg) if dbg else ''
        w('- **`%s%s`** — %s%s' % (n, params, 'no emit site anywhere.' if not emits[n]
                                   else 'no production emit site.', note))
    w('')
    w('## Every signal')
    w('')
    w('`E` = production emit sites · `L` = production listen sites. Debug-only sites are')
    w('excluded from both counts and shown in the notes column when they are all a signal has.')
    w('')
    cur = None
    for name, params, section in signals:
        if section != cur:
            cur = section
            w('')
            w('### %s' % section)
            w('')
            w('| signal | payload | emitter(s) | E | L | listener(s) |')
            w('|---|---|---|---|---|---|')
        pe, pc = prod(emits[name]), prod(conns[name])
        listeners = [owner_of(pc)] if pc else []
        if name in heard:
            listeners.append('EvSignals (card trigger)')
        elif name in bound:
            listeners.append('EvSignals (bindable)')
        w('| `%s` | `%s` | %s | %d | %d | %s |'
          % (name, params.strip('()') or '—', owner_of(pe), len(pe), len(pc),
             ' · '.join(listeners) or '—'))
    w('')

    os.makedirs('docs', exist_ok=True)
    with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(L))
    print('wrote %s — %d signals, %d without emitter, %d without listener'
          % (OUT, len(signals), len(no_emit), len(no_listen)))


if __name__ == '__main__':
    main()
