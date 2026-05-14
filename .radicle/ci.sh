#!/usr/bin/env bash
set -euo pipefail

b=rad/ci
rid=$(rad inspect --rid | sed 's/^rad://')
sha=$(git rev-parse HEAD)
keep=90
log=.radicle/ci/${sha}.log
uri=rad://$rid/$b/$log

git fetch rad $b || true

# worktree to not mess up
w=$(mktemp -d)
git worktree add --detach $w HEAD
git -C $w checkout --orphan $b
git -C $w rm -rf . >/dev/null || true
git -C $w clean -fd

git -C $w checkout rad/$b -- .radicle/ci || true
mkdir -p $w/.radicle/ci

# cleanup old logs
find $w/.radicle/ci -maxdepth 1 -type f -name '*.log' -mtime +$keep -delete || true

# CI job itself
if ! rad-job show $sha >/dev/null; then rad-job new $sha; fi
run=$(rad-job run $sha $uri)

{ make contract_build && make contract_test; } 2>&1 | tee -a $w/$log

rc=${PIPESTATUS[0]}
if [ $rc -eq 0 ]; then status=succeeded; else status=failed; fi

git -C $w add -f .radicle/ci
git -C $w commit --no-verify -m "ci $status ${sha:0:7}"
git -C $w push --force rad $b

git worktree remove -f $w

rad job $status $sha $run
echo "[ci] $status $uri"
exit $rc
