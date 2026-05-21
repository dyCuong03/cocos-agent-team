# Cocos Playable Team — Task Board

Format: `- [ ] PB-001: [type] Description #tag1 #tag2 @role @unassigned`

Status: `[ ]` open → `[~]` in progress → `[x]` done.
Agents poll this file and claim tasks matching their tag list.

---

## 🎨 Design Backlog

- [ ] PB-001: [design] Parse playable spec → list every screen with screen-id #design #screen @design @unassigned
- [ ] PB-002: [design] Wireframe HOOK screen with interaction contract #design #wireframe #ui @design @unassigned
- [ ] PB-003: [design] Wireframe CORE LOOP screen with interaction contract #design #wireframe #ui @design @unassigned
- [ ] PB-004: [design] Wireframe WIN/FAIL feedback screens #design #wireframe #ui @design @unassigned
- [ ] PB-005: [design] Wireframe END CARD / CTA screen #design #wireframe #ui @design @unassigned
- [ ] PB-006: [design] Produce asset request list per screen #design #flow @design @unassigned

---

## 🛠 Cocos Engineer Backlog

- [ ] PB-010: [cocos] Verify Cocos Creator 3.8.x project structure, set up assets/{scenes,prefabs,scripts,textures} #cocos #scene @cocos-engineer @unassigned
- [ ] PB-011: [cocos] Import all assets from design's asset request list #cocos #asset-import @cocos-engineer @unassigned
- [ ] PB-012: [cocos] Build HOOK scene from wireframe #cocos #scene @cocos-engineer @unassigned
- [ ] PB-013: [cocos] Build CORE LOOP scene from wireframe #cocos #scene @cocos-engineer @unassigned
- [ ] PB-014: [cocos] Build END CARD scene from wireframe #cocos #scene @cocos-engineer @unassigned
- [ ] PB-015: [cocos] Extract reusable components into prefabs (button, particle burst, end-card) #cocos #prefab @cocos-engineer @unassigned
- [ ] PB-016: [cocos] Wire animations + particle systems per wireframe #cocos #anim #particle @cocos-engineer @unassigned
- [ ] PB-017: [cocos] Mount typescript-dev's components onto their target nodes #cocos #editor @cocos-engineer @unassigned
- [ ] PB-018: [cocos] Configure web-mobile build settings + run a test build #cocos #build @cocos-engineer @unassigned

---

## 💻 TypeScript Backlog

- [ ] PB-020: [ts] Implement HOOK input handler (swipe/tap/drag per spec) #ts #input #gameplay @typescript-dev @unassigned
- [ ] PB-021: [ts] Implement CORE LOOP state machine #ts #state-machine #gameplay @typescript-dev @unassigned
- [ ] PB-022: [ts] Implement WIN / FAIL state handlers with feedback hooks #ts #logic @typescript-dev @unassigned
- [ ] PB-023: [ts] Implement CTA controller with deep-link / store-open #ts #logic @typescript-dev @unassigned
- [ ] PB-024: [ts] Audio manager (pool AudioSource, mute toggle, sfx hooks) #ts #audio @typescript-dev @unassigned
- [ ] PB-025: [ts] Game controller / scene flow orchestrator #ts #state-machine #gameplay @typescript-dev @unassigned

---

## ✅ QA Backlog

- [ ] PB-030: [qa] Structural pass — every wireframe node exists in built scene #qa #test @qa-tester @unassigned
- [ ] PB-031: [qa] Behaviour pass — every interaction-contract row passes #qa #playtest @qa-tester @unassigned
- [ ] PB-032: [qa] Perf pass — record FPS, bundle size, load time vs project-context budget #qa #perf @qa-tester @unassigned
- [ ] PB-033: [qa] Validation pass — validation_scene + validation_asset clean #qa #regression @qa-tester @unassigned
- [ ] PB-034: [qa] Milestone sign-off — write final report in docs/qa/ #qa #signoff #release @qa-tester @unassigned

---

## In Progress

<!-- Marked [~] tasks appear here visually but stay in their backlog section -->

---

## Done

<!-- Marked [x] when complete -->

---

## QA-Filed Bugs

<!-- qa-tester appends rows here with #qa-bug tag and an @<role> assignee -->
