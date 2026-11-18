# Part E: Git Worktree Architecture & Merge Safety Analysis

---

### (a) Why Git Refuses One Branch in Two Worktrees by Default

Git strictly prohibits checking out the same branch in multiple linked worktrees simultaneously as a concurrency and state-integrity safeguard. In Git's internal architecture, each local branch corresponds to a single mutable reference file (e.g., `.git/refs/heads/main`) storing a 40-character commit SHA. If two worktrees were permitted to check out `main` at the same time:
1. Each worktree would maintain its own working files and independent staging index.
2. Committing changes in Worktree A would advance `refs/heads/main` to a new commit SHA.
3. Worktree B's working directory and index would immediately become out of sync with the branch reference it claims to have checked out, without Worktree B being aware of the advance.
4. Subsequent commits or checkout operations from Worktree B would silently overwrite or fork the commit history, corrupting reflogs and causing lost commits.

To protect developers from this silent desynchronization, Git refuses checkout with exit code 128:
```text
fatal: 'main' is already used by worktree at '/path/to/main-workspace'
```

---

### (b) What is Shared vs. Not Shared Between Worktrees

When creating linked worktrees via `git worktree add`, Git maintains a shared common repository while isolating working states:

* **Shared across all worktrees:**
  - **The Object Store (`.git/objects/`)**: All commit objects, tree structures, file blobs, and annotated tag objects are stored in the common database. A blob committed in one worktree is immediately accessible across all other worktrees.
  - **Branch & Tag References (`.git/refs/`)**: All local branches (`refs/heads/*`), remote tracking references (`refs/remotes/*`), and tags (`refs/tags/*`) are globally shared.
  - **Repository Configuration (`.git/config`)**: Remote URLs, fetch/push refspecs, user credentials, and global workflow configurations apply across all worktrees.
  - **Core Hooks (`.git/hooks/`)**: Lifecycle scripts (such as `pre-commit`, `commit-msg`, and `pre-push`) are centralized.

* **Not shared (isolated per worktree):**
  - **Filesystem Working Copy**: The physical directory containing checked-out project files.
  - **Dedicated `HEAD` Pointer**: Each worktree has its own private `HEAD` pointer located inside `.git/worktrees/<id>/HEAD`, tracking the branch or commit checked out in that specific tree.
  - **Independent Staging Index (`.git/worktrees/<id>/index`)**: Staged changes (`git add`) in one worktree never affect or bleed into the staging area of another worktree.
  - **Operation-Specific State**: Ephemeral operational files (such as `MERGE_HEAD`, `CHERRY_PICK_HEAD`, `REBASE_HEAD`, and bisect state) are strictly isolated within that worktree's metadata directory.

---

### (c) How to Clean Up Stale Worktrees Safely

To safely decommission and clean up Git worktrees without leaving dangling references or corrupted metadata:

1. **Standard Removal**: Always prefer the official removal command:
   ```bash
   git worktree remove <worktree-path>
   ```
   This command inspects the target worktree before deletion. If there are untracked files or uncommitted changes, Git refuses to delete the directory unless explicitly forced (`--force`), preventing accidental data loss.
2. **Metadata Pruning for Deleted Worktrees**: If a worktree directory was deleted manually via filesystem commands (`rm -rf`) or resided on an unmounted drive, Git retains administrative tracking files in `.git/worktrees/`. Prune these stale references using:
   ```bash
   git worktree prune
   ```
   To preview which orphaned references would be purged without actually modifying the repository, run:
   ```bash
   git worktree prune --dry-run
   ```
3. **Status Audit**: Verify the current state of active worktrees at any time using:
   ```bash
   git worktree list
   ```

---

### (d) CTO Claim Verification & Risks of Unreviewed AI Merges

* **CTO Claim Status**: **UNVERIFIED**.
  There is no mention of a native `/worktree-merge` command in the official Claude Code CLI documentation, built-in command catalog (`claude --help`, `claude plugin --help`), or Anthropic developer guides. Claude Code features built-in slash commands such as `/help`, `/clear`, `/compact`, `/cost`, `/doctor`, `/init`, `/login`, `/logout`, `/pr`, and `/review`, but Git branch merging remains delegated to standard Git CLI porcelain (`git merge`) or external scripts. Unless an official Anthropic documentation page can be cited documenting `/worktree-merge`, the claim is classified as UNVERIFIED.

* **Risks of Autonomous AI Merges Without Human Review**:
  1. **Semantic Incompatibilities Despite Syntactic Cleanliness**: Standard Git merge conflict markers only trigger on exact line-level collisions. An autonomous AI merge tool may successfully reconcile syntax while introducing fatal semantic bugs—such as invoking a function whose signature was modified in a concurrent branch, violating cross-module invariants, or introducing race conditions.
  2. **Accidental Deletion of Critical Security Controls**: When conflicting branches modify security hooks, authorization middleware, or schema validation, an unsupervised LLM merge may resolve the conflict by selecting the more permissive branch, inadvertently stripping out defensive guardrails.
  3. **Hallucinated Logic Synthesis**: When confronted with opposing business logic in concurrent feature branches, an LLM prompted to resolve conflicts autonomously may synthesize an entirely novel compromise function that neither developer intended, bypassing peer code review and passing superficial unit tests while breaking downstream production workflows.
  4. **Governance & Audit Trail Compromise**: Automated commits generated without human sign-off obscure responsibility in git blame and audit trails, making post-incident forensic investigations significantly more difficult. Mandatory human review remains essential for all branch integrations into protected production branches.
