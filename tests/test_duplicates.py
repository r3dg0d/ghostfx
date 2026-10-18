"""Guard against near-duplicate shaders (renamed copies, trivial recolours)."""

import re

from ghostfx import meta


def tokens(body: str) -> set[str]:
    code = re.sub(r"//[^\n]*", "", body)
    code = re.sub(r"\d+\.\d+|\d+", "N", code)            # ignore constant tweaks
    toks = re.findall(r"[A-Za-z_]\w*|[^\s\w]", code)
    return {" ".join(toks[i:i + 4]) for i in range(len(toks) - 3)}


def test_no_near_duplicate_shader_bodies():
    shaders = meta.load_all()
    sets = [(s.id, tokens(s.body)) for s in shaders]
    worst = []
    for i in range(len(sets)):
        for j in range(i + 1, len(sets)):
            a, b = sets[i][1], sets[j][1]
            sim = len(a & b) / max(len(a | b), 1)
            if sim > 0.6:
                worst.append((sets[i][0], sets[j][0], round(sim, 2)))
    assert not worst, f"near-duplicate shaders: {worst}"
