"""Interactive terminal browser (curses, stdlib only).

Keys: arrows/jk move, / search, tab next category, enter apply,
p preview window, f favorite, i details, q quit.
"""

from __future__ import annotations

import curses
import textwrap

from . import meta, state
from .meta import CATEGORIES


def run(args) -> int:
    shaders = meta.load_all()
    return curses.wrapper(_loop, shaders, args) or 0


def _loop(scr, shaders, args):
    curses.curs_set(0)
    curses.use_default_colors()
    for i, col in enumerate((curses.COLOR_MAGENTA, curses.COLOR_CYAN, curses.COLOR_YELLOW, curses.COLOR_GREEN), start=1):
        curses.init_pair(i, col, -1)
    cats = ["all"] + [c for c in CATEGORIES if any(s.category == c for s in shaders)]
    cat_i, sel, top, query, message = 0, 0, 0, "", ""
    favs = set(state.load()["favorites"])

    while True:
        cat = cats[cat_i]
        view = [s for s in shaders if (cat == "all" or s.category == cat)]
        if query:
            q = query.lower()
            view = [s for s in view if q in s.id or q in s.name.lower() or any(q in t for t in s.tags) or q in s.description.lower()]
        sel = max(0, min(sel, len(view) - 1))
        h, w = scr.getmaxyx()
        scr.erase()
        title = f" GhostFX · {len(shaders)} shaders · {CATEGORIES.get(cat, 'All categories')} "
        scr.addnstr(0, 0, title.ljust(w), w, curses.color_pair(1) | curses.A_BOLD | curses.A_REVERSE)
        scr.addnstr(1, 0, f" search: {query}_" if query else " / search  tab category  enter apply  p preview  f favorite  q quit", w - 1, curses.A_DIM)
        list_h = h - 4
        listw = min(34, w // 2)
        if sel < top:
            top = sel
        if sel >= top + list_h:
            top = sel - list_h + 1
        for row, s in enumerate(view[top: top + list_h]):
            i = top + row
            star = "★" if s.id in favs else " "
            attr = curses.A_REVERSE if i == sel else 0
            scr.addnstr(2 + row, 0, f"{star} {s.id}".ljust(listw), listw, attr | (curses.color_pair(3) if s.id in favs else 0))
        if view:
            s = view[sel]
            x = listw + 2
            scr.addnstr(2, x, s.name, w - x - 1, curses.color_pair(1) | curses.A_BOLD)
            scr.addnstr(3, x, f"{CATEGORIES[s.category]} · {s.mode}", w - x - 1, curses.color_pair(2))
            y = 5
            for line in textwrap.wrap(s.description, max(10, w - x - 2)):
                if y < h - 2:
                    scr.addnstr(y, x, line, w - x - 1)
                    y += 1
            y += 1
            for label, val in (("tags", ", ".join(s.tags)), ("presets", ", ".join(s.presets)),
                               ("params", ", ".join(p.lower() for p in s.params) or "-")):
                if y < h - 2:
                    scr.addnstr(y, x, f"{label}: {val}", w - x - 1, curses.A_DIM)
                    y += 1
        scr.addnstr(h - 1, 0, message[: w - 1], w - 1, curses.color_pair(4))
        scr.refresh()

        k = scr.get_wch()
        message = ""
        if isinstance(k, str) and query is not None and k not in ("\n", "\t", "\x1b") and getattr(_loop, "searching", False):
            if k in ("\x7f", "\b"):
                query = query[:-1]
            else:
                query += k
            continue
        if k in ("q", "\x1b"):
            if getattr(_loop, "searching", False):
                _loop.searching = False
                continue
            return 0
        if k == "/":
            _loop.searching = True
            query = ""
        elif k in (curses.KEY_DOWN, "j"):
            sel += 1
        elif k in (curses.KEY_UP, "k"):
            sel -= 1
        elif k == curses.KEY_NPAGE:
            sel += list_h
        elif k == curses.KEY_PPAGE:
            sel -= list_h
        elif k == "\t":
            cat_i = (cat_i + 1) % len(cats)
            sel = top = 0
        elif k == curses.KEY_BTAB:
            cat_i = (cat_i - 1) % len(cats)
            sel = top = 0
        elif k == "\n" and view:
            _loop.searching = False
            message = _act(scr, ["apply", view[sel].id])
        elif k == "p" and view:
            message = _act(scr, ["preview", view[sel].id, "--window"])
        elif k == "f" and view:
            sid = view[sel].id
            st = state.load()
            if sid in st["favorites"]:
                st["favorites"].remove(sid)
            else:
                st["favorites"].append(sid)
            state.save(st)
            favs = set(st["favorites"])


def _act(scr, argv) -> str:
    from .cli import main

    curses.endwin()
    print(f"$ ghostfx {' '.join(argv)}")
    rc = main(argv)
    input("\n[press enter to return]")
    scr.refresh()
    return f"ghostfx {' '.join(argv)} → exit {rc}"
