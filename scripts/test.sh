#!/usr/bin/env bash
# Release-integrity check for this thin publish repo. The plugin is built in the
# PUBLIC monorepo CVERInc/tile (it stopped being private on 2026-08-05, and this
# line said otherwise until 2026-08-12); this repo only ships the artifacts
# (main.js, manifest, styles, versions), so there is nothing to compile here.
#
# 🔴 `node --check main.js` below is the ONLY structural gate between tile's build
# output and the community plugin store — scripts/publish.sh runs no tests. tile
# checks its own built main.js now too (2026-08-12), so this is no longer the
# first place a broken bundle would be caught, but it is still the last.
set -euo pipefail
cd "$(dirname "$0")/.."

node -e '
  const fs = require("fs");
  const req = ["id","name","version","minAppVersion","description","author","isDesktopOnly"];
  const m = JSON.parse(fs.readFileSync("manifest.json","utf8"));
  for (const k of req) if (!(k in m)) throw new Error(`manifest.json missing "${k}"`);
  const v = JSON.parse(fs.readFileSync("versions.json","utf8"));
  if (!(m.version in v)) throw new Error(`manifest version ${m.version} is not listed in versions.json`);
  if (v[m.version] !== m.minAppVersion) throw new Error(`versions.json[${m.version}]=${v[m.version]} != manifest.minAppVersion=${m.minAppVersion}`);
  console.log(`manifest/versions OK — ${m.id} ${m.version} (minAppVersion ${m.minAppVersion})`);
'
node --check main.js
echo "main.js parses OK"
