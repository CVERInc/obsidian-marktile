# AGENTS.md — driving marktile as an agent

You are likely an AI coding agent (Claude Code, Codex, Antigravity, …) being asked to
fix, release, or document marktile. Read this before you touch anything, because the
first thing to know is that **the code is not here**. Human-facing intro is in
[README.md](README.md) (four locales); contributor routing is in
[CONTRIBUTING.md](CONTRIBUTING.md).

## What marktile is, in one breath

marktile is a **Markdown editor for [Obsidian](https://obsidian.md) where the markers
never hide** — three modes (Seasoned / Rendered / Plain) over one unmodified file. This
repository is not the editor. It is the **publish mirror**: Obsidian's directory requires
one repo per plugin, with `manifest.json` at the root, `main.js` + `styles.css` beside it,
and a GitHub Release carrying those three files. So this repo holds **build artifacts plus
per-repo docs, and nothing else**. The source — engine, both plugins, tests — is MIT and
public at **[CVERInc/tile](https://github.com/CVERInc/tile)**, and `scripts/publish.sh` there
is what assembles what you see here.

Repository visibility: **PUBLIC** (`CVERInc/obsidian-marktile`). Write every line as if a
stranger reads it, because one will.

## Driving it headless (the part you'll actually use)

```bash
bash scripts/test.sh          # the whole gate: manifest/versions consistency + `node --check main.js`
bash hooks/pre-push           # same thing, via the tracked hook (activate: git config core.hooksPath hooks)
node --check main.js          # the bundle parses (this is all the "test" there is)

git tag                       # released versions — NO `v` prefix here: 0.1.3, not v0.1.3
git describe --tags           # how far this tree has drifted past the last release
gh release list --limit 5     # what users can actually download
```

`scripts/test.sh` is what CI runs (`.github/workflows/ci.yml`, Node 22, ubuntu). There is
no compiler, no bundler, and no dependency to install in this repo.

## Non-negotiable rules (break one and you ship something you shouldn't)

1. **Never hand-edit `main.js`, `styles.css`, or `manifest.json` here.** They are generated.
   An edit here survives exactly until the next assemble from the source, and until then the
   plugin people install differs from the source everybody can read — which is the one thing
   an MIT plugin cannot afford. Fix it in `CVERInc/tile`, then re-assemble.
2. **Bump the version in the source before copying a new bundle in.** Check it: if
   `manifest.json` here and in the source name the same version but the two `main.js` files
   differ in bytes, you are about to ship new code under a version number that already has a
   Release. That build is invisible to Obsidian's updater and to BRAT — users sit on it
   forever. As of 2026-08-06 that gap is real and open: `0.1.3` was released 2026-06-22 and
   the source has moved since without a bump.
3. **`versions.json` must contain exactly the version in `manifest.json`, mapped to that
   manifest's `minAppVersion`.** Obsidian reads it to decide which build an older app may
   install. `scripts/test.sh` asserts both halves; do not "fix" a red gate by editing
   `versions.json` to agree with a manifest you didn't mean to change.
4. **Nothing may live here that the source cannot regenerate**, except `README.md`,
   `CONTRIBUTING.md`, `hooks/`, `scripts/`, `.github/`, and `LICENSE` — those are maintained
   per publish repo and are never overwritten. Anything else you add is silently dropped by
   the next assemble.
5. **No network, ever.** The README promises in four languages that notes never leave the
   vault. Check it, don't assume it: `grep -o -F 'fetch(' main.js | wc -l` and the same for
   `XMLHttpRequest`, `requestUrl`, `WebSocket` must all be `0`. If one isn't, the leak came
   from the source and the answer is upstream, not a patch here.
6. **Commit, then tag, then release — in that order, and only when a human asked.** A tag on
   an uncommitted tree points at bytes nobody else has, and a Release is a public artifact
   with no undo: Obsidian's directory and every BRAT installer start pulling it within
   minutes. There is no release workflow in this repo; every tag and every Release was cut by
   hand, deliberately. User excitement is not authorization.

## Honest scope (don't claim more than is here)

- **There are no behavioural tests in this repo.** `scripts/test.sh` proves the manifest is
  self-consistent and that `main.js` is syntactically valid JavaScript. It does not run the
  editor, and it has never compared these artifacts against any source revision — a bundle
  from the wrong branch would pass it.
- **No build.** You cannot reproduce `main.js` from anything in this checkout.
- **Not on npm. Not on Homebrew.** Distribution is the Obsidian community-plugin directory
  plus GitHub Releases. There is no package manager step to automate.
- **Release assets are the three install files**, uploaded to a tag with no `v` prefix.
- The mode names are localized (Seasoned / アジツケ / 양념 / 調味) — treat the English names
  as the identifiers and the rest as translations, not aliases.

## Where to look

- [README.md](README.md) — what the plugin is, in en / ja / ko / zh-TW.
- [CONTRIBUTING.md](CONTRIBUTING.md) — where code PRs actually go.
- [`scripts/test.sh`](scripts/test.sh) — the entire gate, 20 lines, read it.
- [`hooks/pre-push`](hooks/pre-push) — tracked, opt-in via `git config core.hooksPath hooks`.
- [`.github/workflows/ci.yml`](.github/workflows/ci.yml) — the server-side copy of that gate.
- [CVERInc/tile](https://github.com/CVERInc/tile) — the source: `packages/core` (engine),
  `hosts/obsidian/marktile` (this plugin), the test suite, and `scripts/publish.sh` which builds this payload.
- Sister plugin: [CVERInc/obsidian-tugtile](https://github.com/CVERInc/obsidian-tugtile) — same
  arrangement, same engine.
