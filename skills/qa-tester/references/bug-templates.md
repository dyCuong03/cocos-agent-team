# Bug Templates — qa-tester

Every bug filed by `qa-tester` gets one task-board row **and** one
`memory_save` entry. The row is the queue; the memory entry is the body.

## Task-Board Row Format

```
- [ ] QA-BUG-{NN}: [qa-bug] {one-line summary} #qa-bug #{topic} @<assigned-role> @unassigned
```

Example:

```
- [ ] QA-BUG-007: [qa-bug] CTA button does not fire on second tap in Hook scene #qa-bug #input @typescript-dev @unassigned
```

## agentmemory Entry

```
key:     playable:{slug}:qa:bug:QA-BUG-007
content: |
  Title:        CTA button does not fire on second tap (Hook scene)
  Assigned to:  typescript-dev
  Severity:     P1 (blocks CTA conversion)
  Build:        a1b2c3d
  Steps:        1. Open Hook.scene
                2. Tap CTA — opens store (correct)
                3. Return to playable
                4. Tap CTA again — nothing happens (BUG)
  Expected:     CTA opens store every tap
  Actual:       Second+ tap is a no-op; console shows no log
  Likely cause: Listener removed in CTAController.onDestroy but scene re-uses the same instance — check listener re-registration in onEnable
  Files:        assets/scripts/ui/CTAController.ts
  Linked task:  QA-BUG-007
```

## Severity Levels

| P0 | Blocker — build broken, can't ship, agents must drop other work |
| P1 | High — blocks a core flow (CTA, win state, hook) |
| P2 | Medium — visual or perf glitch that doesn't break the flow |
| P3 | Low — polish, nice-to-have |

A P0 bug pages every active role via `team-chat.md` with explicit `@<role>` mentions. P1+ assigns one role. P2/P3 are batched.

## Per-Role Bug Variants

### For `@cocos-engineer`

```
Title:        {what scene/prefab is wrong}
Likely cause: {missing node, wrong anchor, broken prefab link, asset not imported, etc.}
Reproduce:    1. Open {scene}
              2. {action}
              3. Observe {what's wrong vs. wireframe in docs/design/}
Verify fix:   Re-run validation_scene + validation_asset; visual check vs. wireframe
```

### For `@typescript-dev`

```
Title:        {what behaviour is wrong}
Likely cause: {logic error, listener leak, state machine transition, memory leak}
Files:        {.ts file paths}
Reproduce:    {detailed steps}
Verify fix:   Re-run behaviour pass + memory profile
```

### For `@design`

```
Title:        {what is ambiguous / missing}
Likely cause: Wireframe doesn't specify {X}; engineer/coder guessed
Files:        docs/design/{NN}-{screen}.md
Resolution:   Update the wireframe + interaction contract; flag to other roles via team-chat
Verify fix:   Updated wireframe + downstream artifacts re-verified
```

## Bug Lifecycle

1. **qa-tester** files: row in task-board (`[ ]`) + memory entry
2. **Assignee** picks it up: `[ ] → [~]`, recall memory entry for details
3. **Assignee** fixes + posts in team-chat mentioning `@qa-tester`
4. **qa-tester** re-tests → either:
   - PASS → row to `[x]`, memory entry tagged `resolved`, summary in next QA report
   - FAIL → row back to `[ ]`, add a follow-up note to the memory entry, re-mention assignee
