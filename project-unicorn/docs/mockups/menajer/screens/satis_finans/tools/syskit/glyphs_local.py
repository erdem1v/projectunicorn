"""Glyphs the sheets need that the A2 family (../icons/) does not have yet: the A2 backlog.

Drawn to the A2 family rules (icons/INVENTORY.md): 24 grid, 20 px live area, line 2 with round caps and
joins, a second tone at 40 % of the same colour, meaning always in the line. They exist so every sheet shows
one icon language; A2 owns the final drawings and these names are the request list (SPEC §11.3).
Each value is the inner SVG markup in currentColor.
"""

L = 'fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"'
T = 'fill="currentColor" fill-opacity="0.4"'
F = 'fill="currentColor"'

GLYPHS = {
    # a document: report rows, dossier, file
    "doc": '<path %s d="M6 3.6 H14.2 L18 7.4 V20.4 H6 Z"/><path %s d="M6 3.6 H14.2 L18 7.4 V20.4 H6 Z M14.2 3.6 V7.4 H18 M9 11.4 H15 M9 14.6 H15 M9 17.6 H12.4"/>' % (T, L),
    # a departed sender: person with an outgoing arrow
    "departed": '<circle %s cx="9.4" cy="7.8" r="3.4"/><path %s d="M3.4 20 C3.4 15.6 6 13.4 9.4 13.4 C11.2 13.4 12.8 14 13.8 15.2"/><circle %s cx="9.4" cy="7.8" r="3.4"/><path %s d="M15.4 16.8 H21 M18.4 14.2 L21 16.8 L18.4 19.4"/>' % (T, L, L, L),
    # queued decisions: stacked sheets
    "queue": '<path %s d="M5 9.4 H19 V20 H5 Z"/><path %s d="M5 9.4 H19 V20 H5 Z M7 6.4 H17 M9 3.6 H15"/>' % (T, L),
    # Enter key
    "enter": '<path %s d="M19 5 V12.6 A1.4 1.4 0 0 1 17.6 14 H6.2 M9.6 10.6 L6.2 14 L9.6 17.4"/>' % L,
    # more (three dots)
    "more": '<circle %s cx="6" cy="12" r="1.7"/><circle %s cx="12" cy="12" r="1.7"/><circle %s cx="18" cy="12" r="1.7"/>' % (F, F, F),
    # training: open book
    "training": '<path %s d="M12 6.6 C10 5.2 7 4.8 3.4 5.4 V18.4 C7 17.8 10 18.2 12 19.6 Z"/><path %s d="M12 6.6 C10 5.2 7 4.8 3.4 5.4 V18.4 C7 17.8 10 18.2 12 19.6 C14 18.2 17 17.8 20.6 18.4 V5.4 C17 4.8 14 5.2 12 6.6 Z M12 6.6 V19.6"/>' % (T, L),
    # raise: coin with an up tick
    "raise": '<circle %s cx="10" cy="13.4" r="6.4"/><circle %s cx="10" cy="13.4" r="6.4"/><path %s d="M17.4 9.6 V3.6 M15 6 L17.4 3.6 L19.8 6 M10 10.6 V16.2"/>' % (T, L, L),
    # a seat at the meeting table
    "seat": '<path %s d="M7 4.4 H17 V12.4 H7 Z"/><path %s d="M7 4.4 H17 V12.4 H7 Z M5 12.4 H19 M8 12.4 L7 20 M16 12.4 L17 20 M12 12.4 V16"/>' % (T, L),
    # crown: the current office on the city map
    "crown": '<path %s d="M4 8 L8 12 L12 5.6 L16 12 L20 8 L18.4 18 H5.6 Z"/><path %s d="M4 8 L8 12 L12 5.6 L16 12 L20 8 L18.4 18 H5.6 Z M5.6 20.6 H18.4"/>' % (T, L),
    # milestone flag on a base
    "milestone": '<path %s d="M7 4 H18 L15.4 8 L18 12 H7 Z"/><path %s d="M7 20.4 V3.6 M7 4 H18 L15.4 8 L18 12 H7 M4 20.4 H11"/>' % (T, L),
    # term sheet: a document with a signature stroke
    "termsheet": '<path %s d="M6 3.6 H18 V20.4 H6 Z"/><path %s d="M6 3.6 H18 V20.4 H6 Z M9 8 H15 M9 11.2 H15 M8.6 16.8 C10 14.6 11 18.4 12.4 16.4 C13.2 15.4 13.8 16.8 15.4 16.2"/>' % (T, L),
    # runway: hourglass
    "hourglass": '<path %s d="M8 18.8 C8 15.8 12 14.8 12 13.2 C12 14.8 16 15.8 16 18.8 Z"/><path %s d="M6.4 3.6 H17.6 M6.4 20.4 H17.6 M8 3.6 C8 8 12 9.6 12 12 C12 14.4 8 16 8 20.4 M16 3.6 C16 8 12 9.6 12 12 C12 14.4 16 16 16 20.4"/>' % (T, L),
    # save: tray with a down arrow
    "save": '<path %s d="M4 14 H20 V20.4 H4 Z"/><path %s d="M4 14 V20.4 H20 V14 M12 3.6 V13 M8.4 9.6 L12 13 L15.6 9.6"/>' % (T, L),
    # load: tray with an up arrow
    "load": '<path %s d="M4 14 H20 V20.4 H4 Z"/><path %s d="M4 14 V20.4 H20 V14 M12 13 V3.6 M8.4 7 L12 3.6 L15.6 7"/>' % (T, L),
    # language: globe
    "globe": '<circle %s cx="12" cy="12" r="8.4"/><path %s d="M12 3.6 A8.4 8.4 0 1 0 12 20.4 A8.4 8.4 0 1 0 12 3.6 Z M3.6 12 H20.4 M12 3.6 C9.4 6.4 9.4 17.6 12 20.4 M12 3.6 C14.6 6.4 14.6 17.6 12 20.4"/>' % (T, L),
    # places on the city map
    "home": '<path %s d="M5.6 11 L12 5.4 L18.4 11 V19.6 H5.6 Z"/><path %s d="M3.6 12.6 L12 5 L20.4 12.6 M5.6 11 V19.6 H18.4 V11 M10 19.6 V14.6 H14 V19.6"/>' % (T, L),
    "building": '<path %s d="M5 4 H14 V20.4 H5 Z"/><path %s d="M5 20.4 V4 H14 V20.4 M14 9.6 H19 V20.4 M3.6 20.4 H20.4 M8 7.6 H11 M8 11 H11 M8 14.4 H11"/>' % (T, L),
    "tower": '<path %s d="M8 3.6 H16 V20.4 H8 Z"/><path %s d="M8 20.4 V3.6 H16 V20.4 M5.6 20.4 H18.4 M10.6 7 H13.4 M10.6 10.4 H13.4 M10.6 13.8 H13.4"/>' % (T, L),
    # origins (onboarding): self-made, heir, corporate refugee
    "origin_self": '<path %s d="M4.4 19.6 L9 11.4 L12.2 15 L15.6 8.4 L19.6 19.6 Z"/><path %s d="M3.6 19.6 H20.4 M4.4 19.6 L9 11.4 L12.2 15 L15.6 8.4 L19.6 19.6 M15.6 8.4 V3.6 L19 5"/>' % (T, L),
    "origin_heir": '<circle %s cx="8" cy="9" r="4.4"/><path %s d="M8 4.6 A4.4 4.4 0 1 0 8 13.4 A4.4 4.4 0 1 0 8 4.6 Z M12.4 9 H20.4 M17.4 9 V12.6 M20.4 9 V12"/>' % (T, L),
    "origin_corp": '<path %s d="M4 8.4 H20 V19 H4 Z"/><path %s d="M4 8.4 H20 V19 H4 Z M9 8.4 V5.8 A1.2 1.2 0 0 1 10.2 4.6 H13.8 A1.2 1.2 0 0 1 15 5.8 V8.4 M4 13 H20"/>' % (T, L),
    # sort direction mark for a sortable column head (12 px)
    "sort_down": '<path %s d="M7 9.6 L12 14.6 L17 9.6"/>' % L,
    "sort_up": '<path %s d="M7 14.4 L12 9.4 L17 14.4"/>' % L,
    # a generic head silhouette for the avatar loading placeholder
    "head": '<circle %s cx="12" cy="9" r="4.2"/><path %s d="M4.4 21 C4.4 16.4 7.8 14.4 12 14.4 C16.2 14.4 19.6 16.4 19.6 21 Z"/>' % (F, F),
    # bug (sprint card bug count; A2 owns util/bug, the skill head moves to bug-plus-check)
    "bug": '<path %s d="M8 10 A4 4 0 0 1 16 10 V15 A4 4 0 0 1 8 15 Z"/><path %s d="M8 10 A4 4 0 0 1 16 10 V15 A4 4 0 0 1 8 15 Z M12 11 V19 M8 12.6 H4.6 M16 12.6 H19.4 M8.4 16.4 L5.4 18.6 M15.6 16.4 L18.6 18.6 M9.6 6.8 L7.6 4.4 M14.4 6.8 L16.4 4.4"/>' % (T, L),
}
