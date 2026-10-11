"""Build the MkDocs content from labs/*.md plus a few root files.

Labs stay the single source. This script copies them into .build/, turns
"> **Tip -**" style blockquotes into Material admonitions, rewrites links to
files that live outside the site, and writes the page order to nav.txt.
"""
import re, shutil
from pathlib import Path

root = Path(__file__).resolve().parents[2]
here = Path(__file__).resolve().parent
out = here / ".build"
shutil.rmtree(out, ignore_errors=True)
out.mkdir()
shutil.copytree(root / "docs" / "images", out / "images")
for f in (here / "pages" / "images").glob("*"):
    shutil.copy(f, out / "images" / f.name)

KIND = {"Tip": "tip", "Note": "note", "Gotcha": "warning",
        "Not yet observed": "question", "Verified independently": "success"}
REPO = "https://github.com/sfc-gh-makukreja/AIM_workshop/blob/main/"


def admonish(text):
    lines = text.split("\n")
    res, i, fence = [], 0, False
    while i < len(lines):
        l = lines[i]
        if l.lstrip().startswith("```"):
            fence = not fence
        m = None if fence else re.match(r"> \*\*([^*]+?)\*\* (.*)$", l)
        label = re.sub(r"\s*[-—:]+$", "", m[1].strip()) if m else None
        if m and label in KIND:
            body = [m[2]]
            i += 1
            while i < len(lines) and re.match(r"> ?", lines[i]) and not re.match(r"> \*\*[^*]+?\*\* ", lines[i]):
                body.append(re.sub(r"^> ?", "", lines[i]))
                i += 1
            res += ["", f'!!! {KIND[label]} "{label}"'] + [f"    {x}" if x.strip() else "" for x in body] + [""]
            continue
        res.append(l)
        i += 1
    return "\n".join(res)


def fix_links(text):
    # links that leave the site (repo files) -> absolute GitHub URLs
    return re.sub(r"\]\((?!https?://|#|images/)(\.\./)?((?:snowflake|azure_sql|config|etl)/[^)]+)\)",
                  lambda m: f"]({REPO}{m[2]})", text)


pages = [("Overview", "index.md", (here / "pages" / "intro.md").read_text(encoding="utf-8"))]
for f in sorted((root / "labs").glob("*.md")):
    t = f.read_text(encoding="utf-8")
    m = re.match(r"# Lab (\d+) - (.*)", t) or re.match(r"# Lab (\d+) [—-] (.*)", t)
    pages.append((f"{int(m[1]):02d} {m[2].strip()}" if m else f.stem, f.name, t))
pages.append(("Facilitator guide", "facilitator.md", (root / "azure_sql" / "FACILITATOR.md").read_text(encoding="utf-8")))
pages.append(("Troubleshooting", "troubleshooting.md", (root / "TROUBLESHOOTING.md").read_text(encoding="utf-8")))

nav = []
for title, name, body in pages:
    body = re.sub(r"\n---\s*\n+\*\*Next:\*\*[^\n]*\s*$", "\n", body)
    body = fix_links(admonish(body))
    (out / name).write_text(body + "\n", encoding="utf-8")
    nav.append((title, name))
(out / "nav.txt").write_text("\n".join(f"{t}|{n}" for t, n in nav), encoding="utf-8")

# generate nav into mkdocs.yml (kept in sync with the labs folder)
cfg = (here / "mkdocs.yml").read_text(encoding="utf-8").split("nav:")[0]
(here / "mkdocs.yml").write_text(cfg + "nav:\n" + "\n".join(f'  - "{t}": {n}' for t, n in nav) + "\n", encoding="utf-8")
print("\n".join(f"{n}  <-  {t}" for t, n in nav))
