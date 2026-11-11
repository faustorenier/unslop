---
name: github-project-setup
description: Creates GitHub epics, tasks, a GitHub Project, and a kanban board for a new repository. Use when setting up a new project issue structure, creating a kanban board, or organising GitHub issues from a spec. Feature-grouped tasks, one task per PR.
allowed-tools: Bash(gh *)
---

# GitHub project setup

Follow the process defined in [process.md](process.md).
Use the issue template in [issue-template.md](issue-template.md).
Refer to [gotchas.md](gotchas.md) for common mistakes to avoid.

## Input
If a slice-backlog DAG was just produced, use it as-is: its issue bodies, its `Blocked by`
edges, its ready set. Do not re-derive epics and tasks from scratch.
