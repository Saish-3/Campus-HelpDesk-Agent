#!/usr/bin/env bash
# worktrees.sh: Demonstrates Git worktrees lifecycle, conflicting merges, and cleanup.
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

PARENT_DIR="$(dirname "$REPO_ROOT")"
WT1="$PARENT_DIR/wt-skill-tests"
WT2="$PARENT_DIR/wt-mcp-server"
WT3="$PARENT_DIR/wt-hook-path"
WT_DUP="$PARENT_DIR/wt-dup"

# Clean up any leftover worktrees or branches from previous runs
rm -rf "$WT1" "$WT2" "$WT3" "$WT_DUP" 2>/dev/null || true
git worktree prune 2>/dev/null || true
git branch -D feature/skill-tests feature/mcp-server bugfix/hook-path 2>/dev/null || true

echo "================================================================================"
echo "STEP 1: Create three linked worktrees"
echo "================================================================================"
git worktree add -b feature/skill-tests "$WT1" main
git worktree add -b feature/mcp-server "$WT2" main
git worktree add -b bugfix/hook-path "$WT3" main

echo ""
echo "================================================================================"
echo "STEP 2: Commit changes in each worktree (with conflicting edits on README.md line 1)"
echo "================================================================================"

# 1. Commit in bugfix/hook-path (non-conflicting edit at bottom of README)
cd "$WT3"
echo -e "\n<!-- Verified Hook Path Bugfix Applied -->" >> Campus-Helpdesk-Agent/README.md
git add Campus-Helpdesk-Agent/README.md
git commit -m "fix(hooks): update hook path resolution documentation"

# 2. Commit in feature/skill-tests (edits line 1 of README)
cd "$WT1"
sed -i '' '1s/.*/# Campus Helpdesk Agent (Enhanced Skill Test Suite)/' Campus-Helpdesk-Agent/README.md
git add Campus-Helpdesk-Agent/README.md
git commit -m "feat(skills): add enhanced skill test suite and documentation"

# 3. Commit in feature/mcp-server (edits the SAME line 1 of README)
cd "$WT2"
sed -i '' '1s/.*/# Campus Helpdesk Agent (Enterprise MCP Server Integration)/' Campus-Helpdesk-Agent/README.md
git add Campus-Helpdesk-Agent/README.md
git commit -m "feat(mcp): upgrade enterprise stdio mcp server"

cd "$REPO_ROOT"

echo ""
echo "================================================================================"
echo "STEP 3: Merge worktree branches into main and resolve conflict"
echo "================================================================================"

# Merge bugfix/hook-path cleanly
echo "--- Merging bugfix/hook-path into main ---"
git merge --no-ff bugfix/hook-path -m "Merge branch 'bugfix/hook-path' into main"

# Merge feature/skill-tests cleanly
echo "--- Merging feature/skill-tests into main ---"
git merge --no-ff feature/skill-tests -m "Merge branch 'feature/skill-tests' into main"

# Merge feature/mcp-server -> triggers conflict on line 1 of README.md
echo "--- Merging feature/mcp-server into main (expecting conflict) ---"
set +e
git merge --no-ff feature/mcp-server
MERGE_EXIT=$?
set -e

if [ $MERGE_EXIT -ne 0 ]; then
    echo ""
    echo ">>> Conflict successfully triggered as expected! <<<"
    echo "--- Conflict markers in Campus-Helpdesk-Agent/README.md (first 10 lines) ---"
    head -n 10 Campus-Helpdesk-Agent/README.md
    echo ""
    echo "--- Resolving conflict by combining both feature titles ---"
    python3 -c '
with open("Campus-Helpdesk-Agent/README.md", "r") as f:
    lines = f.readlines()
# Find end of conflict markers
idx = 0
for i, line in enumerate(lines):
    if line.startswith(">>>>>>>"):
        idx = i + 1
        break
resolved_content = ["# Campus Helpdesk Agent (Enhanced Skill Tests & Enterprise MCP Server)\n"] + lines[idx:]
with open("Campus-Helpdesk-Agent/README.md", "w") as f:
    f.writelines(resolved_content)
'
    head -n 5 Campus-Helpdesk-Agent/README.md
    git add Campus-Helpdesk-Agent/README.md
    git commit -m "Merge branch 'feature/mcp-server' into main (resolved line 1 README conflict)"
    echo ">>> Conflict resolved and committed successfully! <<<"
fi

echo ""
echo "================================================================================"
echo "STEP 4: Display git worktree list and git log --oneline --graph --all"
echo "================================================================================"
echo "--- git worktree list ---"
git worktree list

echo ""
echo "--- git log --oneline --graph --all (last 10 commits) ---"
git log --oneline --graph --all -n 10

echo ""
echo "================================================================================"
echo "STEP 5: Demonstrate refusal when checking out 'main' in another worktree"
echo "================================================================================"
echo "$ git worktree add ../wt-dup main"
set +e
git worktree add "$WT_DUP" main 2>&1
REFUSAL_EXIT=$?
set -e
echo "Exit code: $REFUSAL_EXIT"

echo ""
echo "================================================================================"
echo "STEP 6: Clean up worktrees with git worktree remove and git worktree prune"
echo "================================================================================"
git worktree remove "$WT1"
git worktree remove "$WT2"
git worktree remove "$WT3"
git worktree prune

echo ""
echo "--- git worktree list after cleanup ---"
git worktree list

echo ""
echo "All worktree operations and cleanup completed successfully!"
