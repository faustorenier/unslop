## Workflow

- Planning: `/planning:grill-me` → `/planning:to-ticket` or `/planning:to-prd` →
  `/planning:to-tickets`. Linear issues live in the team named in `.linear.toml`.
- One issue, inside Herdr: `/rig:dev-loop <ISSUE>`. A developer and a reviewer agent, set in
  `loop-models.json`, work in Herdr panes; it pushes the branch, opens the PR and leaves the issue
  In Review. The user merges. Delicate issues, or outside Herdr: `/core:tdd <ISSUE>`.
- Whole project, inside Herdr: `auto-dev "<project>" [max-issues] [base]`. Issues merge into
  `auto/<project-slug>`; when nothing is left it opens one PR into `main`. The user merges.
- Running `/rig:dev-loop` authorizes commits on the issue branch, pushing it and opening its PR.
  Running `auto-dev` also authorizes merging and pushing to the base branch. Nothing ever deploys.
- Both run the rig preflight first: CLIs, auth, the Linear team, Herdr, `loop-models.json` and the
  commands below.
- Branches, commits and PR titles follow `core:git`. Linear follows `planning:linear`.

## Verification

```sh
{{VERIFICATION_COMMANDS}}
```
