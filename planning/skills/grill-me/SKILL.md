---
name: grill-me
description: Interrogates the user relentlessly about a feature or product idea until there is genuine shared understanding, before any planning or code. Use when the user says "grill me", describes a new feature or product, brings a vague brief, says "I want to build X", or asks to start planning something not yet fully specified.
---

# Grill me

Your job is **not** to produce a document. It is to reach genuine shared understanding
of the design before a single line of code exists. The transcript of this conversation
is the real asset — it gets reused during planning and implementation.

## Hard rules

- **Do not write code. Do not write files. Do not propose a plan.** Only questions.
- Ask **one question at a time**, or a tight cluster of at most three related ones.
  Never dump a numbered list of 20 questions — the user cannot answer them well.
- Expect **40–100 questions** across the session. Do not stop early because the idea
  "seems clear". It is not clear until the design tree has no unexplored branches.
- When the user gives a vague answer ("it should be fast", "standard auth", "the usual"),
  **do not accept it**. Push: fast for how many users? standard meaning which flow?
- When the user says "I don't know" or "you decide": propose 2–3 concrete options with
  the tradeoff of each, and ask them to pick. Never silently choose.
- Record every decision as it is made. Restate it back in one line so the user can
  correct you immediately.

## Method: walk the design tree

Traverse depth-first. Fully resolve one branch before moving to the next, and resolve
dependencies before the things that depend on them.

1. **Problem and user** — Who has this problem today? What do they do instead right now?
   How do we know they'd switch? What is explicitly *not* in scope?
2. **Success criteria** — What observable thing is true when this is done? What number
   moves? How is it measured, and by what?
3. **Domain model** — What are the nouns? What are the invariants that must never be
   violated? Which entities own which data? What are the lifecycles and state transitions?
4. **Boundaries** — What are the external systems, APIs, auth providers, payment rails?
   What happens when each one is down or slow? Who owns those credentials?
5. **Data** — Where does data live? What is the schema? What migrates? What is the
   retention and deletion story? Any PII or regulated data?
6. **Interface contracts** — What are the actual API shapes? Request, response, error
   codes. What does the client do with each error?
7. **Edge cases and failure** — Concurrency, retries, idempotency, partial failure,
   empty states, permission denied, rate limits. Ask for each one explicitly.
8. **Non-functional** — Expected load, latency budget, cost ceiling, security posture,
   observability, rollout and rollback.
9. **Constraints and taste** — Existing stack, existing conventions, things the user
   refuses to use, deadline, team size.

## Adaptive depth

Calibrate on the answers, not on a fixed script:

- Answer is confident and specific → move on immediately, don't pad.
- Answer is hedged, or two answers contradict each other → stop and drill until resolved.
  Contradictions are the highest-value thing you can find in this session.
- User is inventing the answer on the spot → say so, and ask whether this is a decision
  or a guess. Guesses get flagged as open questions.

## Closing

You are done when you can restate the design and the user has nothing to correct.
Then, and only then:

1. Print **Decisions** — a flat list of every resolved decision, one line each.
2. Print **Open questions** — everything still a guess, with who/what unblocks it.
3. Print **Risks** — where the design is most likely to be wrong.
4. Ask: *"Ready to turn this into a PRD?"* — and stop. Do not write the PRD unless
   the user says yes.
