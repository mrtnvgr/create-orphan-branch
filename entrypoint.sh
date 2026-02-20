#!/bin/bash

set -euo pipefail

# mark workspace dir as 'safe'
git config --system --add safe.directory "/github/workspace"

# validate
[ -z "$1" ] && echo "ERROR: branch-name is a required input" && exit 1
BRANCH_NAME="$1"

git config user.name "github-actions[bot]"
git config user.email "actions@users.noreply.github.com"

# make sure we've got all branches from the remote
# fetched locally before we call `git show-branch`
# (actions/checkout does not fetch all branches)
git fetch

# check if the branch already exists
if git show-branch "remotes/origin/$BRANCH_NAME"; then
    echo "INFO: branch $BRANCH_NAME already exists, exiting..."
    exit 0
fi

# if it doesn't exist, create one
echo "INFO: branch $BRANCH_NAME does not exist, creating a new orphan branch..."

# store the currently checked out branch before we start
CURRENT_BRANCH=$(git branch --show-current)
[ -z "$CURRENT_BRANCH" ] && echo "ERROR: I don't know how to cleanup, exiting..." && exit 1

git checkout --orphan "$BRANCH_NAME"

git rm -rf .
rm -f .gitignore

git commit --allow-empty -m "Initial commit"
git push origin "$BRANCH_NAME"

git checkout --force "$CURRENT_BRANCH"
