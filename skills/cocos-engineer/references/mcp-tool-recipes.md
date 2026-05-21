# MCP Tool Recipes — Cocos Engineer

Copy-paste sequences for the most common operations. Every recipe is a
shorthand; consult `scene_hierarchy` first to know the live state.

## Recipe 1 — Create a Tappable Button From Scratch

```
1. node_lifecycle (create)
     parent: "Canvas"
     name:   "CTA"
     components: ["UITransform", "Sprite", "Button", "Label"]

2. set_component_property (batch on CTA)
     UITransform.contentSize    = { width: 600, height: 120 }
     UITransform.anchorPoint    = { x: 0.5, y: 0.5 }
     Sprite.spriteFrame         = "assets/textures/cta_bg.png"

3. node_lifecycle (create child)
     parent: "Canvas/CTA"
     name:   "Label"
     components: ["UITransform", "Label"]

4. set_component_property (Canvas/CTA/Label.Label)
     string     = "Play Now!"
     fontSize   = 48
     color      = { r:255, g:255, b:255, a:255 }

5. component_script (mount custom)
     node:   "Canvas/CTA"
     script: "CTAController"
```

## Recipe 2 — Extract a Reusable Prefab

```
1. node_query name="RewardBurst"
2. prefab_lifecycle (createFromNode)
     node:      "Canvas/CoreLoop/RewardBurst"
     savePath:  "assets/prefabs/fx/RewardBurst.prefab"
3. prefab_instance (link existing instance)
     instances: ["Canvas/CoreLoop/RewardBurst"]
     prefab:    "assets/prefabs/fx/RewardBurst.prefab"
4. scene_management (save)
```

## Recipe 3 — Batch-Import a Sprite Sheet

```
1. asset_manage (importBatch)
     files: ["assets/raw/player_idle_0.png", ..., "_3.png"]
     destFolder: "assets/textures/player/"

2. asset_manage (createAtlas)
     name:    "player_atlas"
     sources: ["assets/textures/player/*.png"]
     output:  "assets/atlases/player_atlas.plist"

3. asset_system (refresh)
4. asset_query (verify) by folder "assets/atlases"
```

## Recipe 4 — Mount typescript-dev's Component

The typescript-dev's file header tells you the mount path + `@property`
bindings. Example header:

```
// Mount: Canvas/Hook/Player
// Props: target (Node) = Canvas/Hook/Target ; swipeThreshold (number) = 50
```

Translate to:

```
1. component_script (add)
     node:   "Canvas/Hook/Player"
     script: "SwipeHook"

2. set_component_property
     node:   "Canvas/Hook/Player"
     component: "SwipeHook"
     properties:
       target:          node_ref("Canvas/Hook/Target")
       swipeThreshold:  50
```

## Recipe 5 — Run a Test Build

```
1. project_build_system (openBuildPanel)
2. project_build_system (setOptions)
     platform:   "web-mobile"
     buildPath:  "build/web-mobile"
     minify:     true
3. project_manage (build)
4. debug_console (read) — verify no red lines
5. Save to agentmemory: build hash, output size, warnings
```

## Recipe 6 — Pre-Mutation Sanity Check

Before any destructive operation:

```
1. scene_hierarchy        — know the current tree
2. asset_analyze (target)  — find dependents (if deleting an asset)
3. memory_smart_search    — any prior decision on this node/asset?
```

If anything looks unfamiliar — that's the user's in-progress work. Stop and ask in team-chat.
