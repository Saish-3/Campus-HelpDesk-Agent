# Reflection: Agent Architecture, Tool Selection, and Human-in-the-Loop Governance

### 1. Distinct Problem Domains
Among Skills, Plugins, MCP, and Git Worktrees, **Git Worktrees** solve a fundamentally different category of problem from the others. While Skills, Plugins, and MCP operate exclusively within the AI agent runtime layer to define capabilities, distribution packages, and protocol-level integrations, Git Worktrees operate at the underlying developer infrastructure and version-control level. Worktrees solve local filesystem isolation, enabling concurrent branches to be checked out, built, and tested in parallel without destructive context switching. Within the agentic layer itself, Plugins act as deployment containers, MCP provides standardized cross-process RPC communication for external services, and Skills provide in-context procedural guidance.

### 2. When to Choose a Skill Over an MCP Tool
Choose a **Skill** when the primary objective is to govern the agent's internal reasoning, enforce strict domain policies, or provide progressive procedural instructions—such as our zero-hallucination timetable rules, query ambiguity handling, and data edge-case protocols. Skills live inside the agent's context window, shaping *how* the model reasons about a task and when it should refuse to guess. Conversely, choose an **MCP Tool** when you need a decoupled, language-agnostic interface to communicate with external infrastructure, query live databases, execute network APIs, or serve dynamic system resources over standard protocols. In short: use Skills for cognitive workflows and behavioral guardrails; use MCP for standardized external service execution.

### 3. What Should Never Be Delegated Without Human Review
Autonomous agents should never be granted unsupervised authority over actions that cause irreversible state mutations, security privilege escalation, or legal/financial consequences. Specifically:
- **Destructive Data Operations**: Unvetted deletions, database migrations (`DROP TABLE`), or modifications to protected source datasets (such as `timetable.csv`).
- **Security & Infrastructure Configuration**: Altering IAM policies, modifying lifecycle hooks (`hooks.json`), generating production credentials, or bypassing write-protection scripts.
- **Production Code Integration**: Merging concurrent branches into protected branches (`main`) without human peer review and automated CI verification.
- **Consequential Administrative Actions**: Official student fee adjustments, academic record updates, or dispatching external communications without explicit human sign-off.
