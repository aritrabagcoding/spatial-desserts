# Spatial Desserts of Bengal

> *"Get a sneak peek into the future of cooking."*

**Spatial Desserts of Bengal** is an immersive, gamified iPad application that merges cultural heritage, spatial computing, and modern iOS engineering into a single cohesive experience. Built entirely in Swift Playgrounds, the app takes the user on an interactive culinary journey through iconic Bengali sweet recipes using Augmented Reality (AR) as its primary canvas.

The experience is structured around a loop of three interconnected phases: **unlock a recipe by solving a puzzle, cook it using an AR workspace anchored to real-world surfaces, and log your experience through sentiment-analyzed feedback.** Every dessert is a self-contained mission, and every mission contributes to a growing personal collection.

---

## Table of Contents

1. Concept & Motivation
2. Application Flow
3. Feature Breakdown
4. The Dessert Catalogue
5. Technical Architecture
6. Project Structure
7. Framework Deep Dive
8. Data Model & Persistence
9. Design System
10. Requirements

---

## Concept & Motivation

Bengali sweets — known as *mishti* carries centuries of tradition, specific techniques, and a distinct identity tied to the region. This app presents them in an interactive or technologically immersive format.

**Spatial Desserts of Bengal** was created to answer a simple question: *What if your recipe book existed not on a screen, but floating in the physical world around you as you cook?*

The app positions your real kitchen table as the stage. By detecting flat horizontal surfaces through ARKit, it spawns a fully interactive virtual kitchen workspace — complete with a step-by-step instruction panel, a live ingredients board, and a countdown timer — all hovering above your actual countertop in three dimensions. This transforms the act of following a recipe from a passive screen-reading exercise into a spatially engaged, hands-free cooking experience.

The gamification layer — the jigsaw puzzle that must be solved before cooking can begin — is a deliberate design choice. It serves as a moment of discovery, encouraging the user to look closely at each dish as they piece together its image, creating a sense of anticipation before the AR session starts.

---

## Application Flow

The application is organized around five primary states, managed by a central integer mode in `ContentViewModel`. Navigation between them is seamlessly animated with `easeInOut` transitions throughout.

```
HOME (mode: 0)
  │
  ├──► GALLERY (mode: 1)         — Select a recipe to attempt
  │         │
  │         └──► GAME (mode: 3)  — The main gameplay loop
  │                   │
  │                   ├── Phase 1: PUZZLE  — Solve the jigsaw to unlock
  │                   ├── Phase 2: AR      — Cook in Augmented Reality
  │                   └── Phase 3: DEBRIEF — Submit feedback & log results
  │
  └──► COLLECTION (mode: 4)      — Browse completed & rated recipes
```

### Home Screen
The entry point features a full-bleed background image with a warm red gradient fallback, a bold gold-tinted typographic title, and two primary navigation actions: **Start Cooking** (leads to the gallery) and **Collection** (leads to the personal cookbook). A music note button in the top toolbar opens an audio settings sheet with a volume slider, providing in-app control over the looping background music without leaving the home screen.

### Gallery Screen
A responsive `LazyVGrid` layout displays all ten recipes as card-style tiles. Each card shows the dish's image, name, and a clear status badge — `NOT STARTED`, `IN PROGRESS`, or `SERVED` — making the user's overall progress visible at a glance. Completed recipes receive a green border stroke as a visual reward. Tapping a card launches directly into the game view for that recipe. A context menu on in-progress cards allows resetting puzzle progress, offering the user a clean restart when needed.

### Game Screen
The heart of the application. This screen hosts all three gameplay phases through a `subMode` state that transitions the view between them. The puzzle phase occupies the full screen as a `SpriteKit` canvas, the AR phase takes full control of the camera feed via `RealityKit`, and the debrief phase presents the feedback interface on completion.

### Collection Screen
A personal record of the user's culinary history. It is organized into three categories: recipes the user enjoyed (positive sentiment), recipes they did not (negative sentiment), and all completed puzzles. Each category is presented with a distinct icon and color. Tapping into a category shows a grid of matching recipes, and tapping a specific recipe opens a full-screen detail view showing the dish image, the user's original written feedback, and their assigned emoji mood. From this detail view, the user can jump directly back into AR cooking or remove the entry from their collection.

---

## Feature Breakdown

### Jigsaw Puzzle — Recipe Unlock Mechanic

Before any recipe can be cooked, it must be unlocked. The unlock mechanism is a custom four-piece jigsaw puzzle built entirely in SpriteKit, where the image of the recipe's finished dish is divided into four triangular wedges emanating from the center.

Each piece is an `SKNode` composite assembled from three layers:
- A **shadow node** (`SKShapeNode`) that appears slightly offset during dragging to give a sense of physical lift.
- A **content node** (`SKCropNode`) that clips the full dish image into the triangular shape of that piece.
- A **border node** (`SKShapeNode`) with a white stroke to clearly delineate piece edges.

Pieces spawn randomly in the lower portion of the screen. The user drags them toward the center target zone. When a piece is dragged close enough to its correct position (within a snap distance ratio of the screen width), it locks into place with a subtle scale-up animation and a brief golden glow along its border. A real-time progress bar in the HUD reflects completion as a fraction of locked pieces over total pieces.

Puzzle state is serialized as a JSON string and persisted in SwiftData, so a partially completed puzzle can be resumed exactly where the user left off after closing the app. Upon full completion, a brief delay triggers the transition to the AR phase.

### Augmented Reality Cooking Workspace

The AR cooking experience is the centrepiece of the application. It uses ARKit's world-tracking configuration with horizontal plane detection to identify flat surfaces in the real world — a kitchen table, a countertop — and uses a raycasting reticle to guide the user toward an appropriate placement point.

Once a surface is detected, the reticle turns green and a prompt instructs the user to tap. On tap, three interactive floating panels are spawned and anchored to the physical world:

**1. Instruction Panel (Quest Panel)**
The largest panel, rendered as a flat `ModelEntity` with a dark background and a system-generated glowing blue border. It displays the current step number and its full descriptive text, loaded dynamically from the recipe's `steps` array. Previous and next navigation buttons are embedded directly on the 3D surface of this panel, created programmatically using `ARPanelFactory`. Each button tap triggers a haptic pulse animation on the panel itself, providing physicality to an otherwise virtual interaction.

**2. Timer Panel**
A smaller companion panel that displays the suggested time estimate for the current step (`Est: X min`), derived from the recipe's `stepTimer` array. It features a visual progress bar — a `ModelEntity` that scales its X-axis and changes color from green to red as time runs low — updated in the scene's `SceneEvents.Update` loop. The user can also set a manual countdown timer (1–60 minutes) via a bottom-sheet picker in the HUD, with a live display of remaining time using SwiftUI's `TimelineView`.

**3. Ingredients Panel**
A vertically oriented panel listing all ingredients and the yield for the recipe (`INVENTORY (X Servings):`), formatted clearly for quick reference mid-cooking.

All three panels support the full suite of RealityKit gestures installed via `installGestures`: drag to reposition, pinch to scale, and two-finger twist to rotate. Scale is clamped in the update loop (0.6x minimum, 1.5x maximum) to prevent accidentally making panels unusably small or excessively large.

A dedicated **Edit Mode** allows the user to long-press any panel to select it, then use a height slider to adjust its vertical position between 0.3m and 0.8m above the anchor plane. This is critical for ergonomic comfort — a user who places the anchor on a low coffee table may need their panels higher than a user at a standard kitchen counter.

The entire AR session can be reset via a RESET button, which clears all anchors, restarts plane detection, and replays the coaching overlay. The ARKit coaching overlay is integrated and automatically activates and deactivates in sync with panel visibility.

### AR Tutorial & Safety System

Before the AR camera feed is fully engaged, the user passes through a two-step onboarding gate:

1. **AR Tutorial Overlay**: A full-screen dark overlay that presents gesture instructions — how to scan, how to drag, pinch, and rotate panels. The user dismisses it by tapping START.
2. **Kitchen Safety Overlay**: An ultra-thin material blur overlay presenting seven specific kitchen safety guidelines (e.g., keeping the device away from open flames, putting down knives before interacting with the UI). The user must explicitly tap "I UNDERSTAND & AGREE" to proceed. This overlay uses `ScrollView` to ensure all guidelines are readable on any screen size.

This sequential gating is enforced in `GameViewModel` and cannot be bypassed, ensuring every AR session begins from an informed and safe starting point.

### Sentiment-Analyzed Feedback (Debrief)

After completing the AR cooking phase, the user is presented with a debrief screen inviting them to describe their experience in free text. On submission, the text is analyzed asynchronously using Apple's **NaturalLanguage** framework — specifically `NLTagger` with the `.sentimentScore` tag scheme.

The sentiment score (a `Double` from -1.0 to +1.0) is mapped to one of four moods:
- Score greater than 0.5 (very positive)
- Score greater than 0 (positive)
- Score greater than -0.5 (neutral to slightly negative)
- Score of -0.5 or below (negative)

These emoji based moods, along with the original feedback text, are saved to the recipe's SwiftData record. The result automatically categorizes the completed recipe into the appropriate section of the Collection view, creating a dynamic personal cookbook sorted by the user's own feelings. No server, no ML model download, no network request — all inference runs on-device through Apple's built-in NLP stack.

### Audio Management

Background music begins playing immediately on app launch via `AuMgr.shared.playBGM()`, before any view appears. The audio manager is a `@MainActor @Observable` singleton built on `AVAudioPlayer` with `numberOfLoops = -1` for seamless looping.

The system handles audio session interruptions gracefully — if a phone call or another audio-producing app takes focus, playback pauses automatically and resumes when the interruption ends (if the system permits). When the AR session starts, the background music pauses to reduce cognitive noise; when the AR session exits to the debrief phase, it resumes. Volume is user-adjustable from the settings sheet on the home screen without leaving the app.

---

## The Dessert Catalogue

The app ships with ten authentic Bengali sweet recipes, each with detailed multi-step instructions, per-step time estimates, and a full ingredient list:

| # | Dessert |
|---|---------|
| 1 | **Rosogolla** |
| 2 | **Mishti Doi** |
| 3 | **Sandesh** |
| 4 | **Pantua** |
| 5 | **Langcha** |
| 6 | **Chomchom** |
| 7 | **Jilipi** |
| 8 | **Mihidana** |
| 9 | **Moa** |
| 10 | **Ras Malai** |

All recipe data is stored in a `Recipes.json` resource file bundled with the app, with a complete hardcoded fallback embedded directly in `RecipeDataService.swift`. This dual-source architecture means the app remains fully functional even if the JSON file fails to load, ensuring a robust first-run data seeding experience via SwiftData.

---

## Technical Architecture

The application follows a clear **MVVM (Model-View-ViewModel)** pattern, with a distinct separation of concerns across every layer.

### Pattern Overview

```
┌──────────────────────────────────────────────────┐
│                      VIEW LAYER                  │
│  HomeView  GalleryView  GameView  CollectionView │
│  DebriefView  ARTutorialView  SafetyOverlay      │
└──────────────────────┬───────────────────────────┘
                       │ binds / observes
┌──────────────────────▼───────────────────────────┐
│                   VIEWMODEL LAYER                │
│  ContentViewModel  GameViewModel  DebriefViewModel│
└──────────────────────┬───────────────────────────┘
                       │ reads / mutates
┌──────────────────────▼───────────────────────────┐
│                    MODEL LAYER                   │
│  RecipeModel (SwiftData)  RecipeDataService      │
│  DataSeeder               RecipeJSON (Codable)   │
└──────────────────────────────────────────────────┘
                       │ persisted by
┌──────────────────────▼───────────────────────────┐
│                   SWIFTDATA STORE                │
│  ModelContainer  ModelContext  FetchDescriptor   │
└──────────────────────────────────────────────────┘
```

### State Management

Navigation state is centralized in `ContentViewModel` as a single `mode: Int`, making the root `ContentView` a pure switch statement with zero business logic. This keeps the root coordinator lean and predictable.

Within the game loop, `GameViewModel` manages a `subMode: Int` that transitions between puzzle (0), post-puzzle transition (1), AR cooking (2), and debrief (3). All AR-specific state — surface detection, content placement, timer, edit mode — lives in `GameViewModel` and is passed into the AR layer by reference, keeping SwiftUI and RealityKit cleanly decoupled.

All ViewModels are marked `@Observable` and `@MainActor` to guarantee UI state mutations occur on the main thread.

---

## Project Structure

```
Spatial_Desserts_Of_Bengal.swiftpm/
│
├── App/
│   ├── ChefApp.swift          # @main entry point, ModelContainer setup, data seeding
│   └── ContentView.swift      # Root navigation switch, mode-based view routing
│
├── Model/
│   ├── RecipeModel.swift      # SwiftData @Model class + RecipeJSON Codable struct
│   ├── RecipeDataService.swift # JSON loading from bundle with hardcoded fallback
│   └── DataSeeder.swift       # First-run seeding coordinator
│
├── ViewModel/
│   ├── ContentViewModel.swift # App-level mode & selected recipe state
│   ├── GameViewModel.swift    # Puzzle progress, AR state, timer, edit mode
│   └── DebriefViewModel.swift # Feedback text, NLTagger sentiment analysis
│
├── View/
│   ├── HomeView.swift         # Landing screen with title, navigation & audio settings
│   ├── GalleryView.swift      # Recipe grid with status badges & context menu
│   ├── GameView.swift         # Master game view, hosts puzzle/AR/debrief sub-views
│   ├── CollectionView.swift   # Personal cookbook with category browsing & detail view
│   ├── DebriefView.swift      # Post-cook feedback form with sentiment submission
│   ├── ARTutorialView.swift   # First-time AR gesture instruction overlay
│   └── SafetyOverlay.swift    # Mandatory kitchen safety checklist before AR
│
├── ARComponents/
│   ├── ARCookingView.swift    # UIViewRepresentable bridging ARView into SwiftUI
│   ├── ARCoordinator.swift    # ARSessionDelegate, panel spawning, gesture routing
│   ├── ARPanelFactory.swift   # Factory for creating 3D mesh panels and text entities
│   └── ARGestureHandler.swift # Tap and long-press gesture recognizer management
│
├── Puzzle/
│   ├── PuzzleGameScene.swift  # SKScene: piece spawning, touch handling, snap logic
│   └── PuzzlePiece.swift      # SKNode composite: shadow, crop-masked content, border
│
├── Services/
│   └── AudioManager.swift     # AVAudioPlayer singleton, BGM, interruption handling
│
├── Utilities/
│   ├── AppConstants.swift     # All string literals, layout constants, icon names
│   ├── Pal.swift              # Global color palette (SwiftUI Color + UIColor)
│   ├── GameConfig.swift       # Puzzle piece scale and snap distance ratios
│   └── Extensions.swift       # Helpers: Color(hex:), Image.safe(), UIImage.safe()
│
├── Resources/
│   ├── Recipes.json           # Primary recipe data source
│   └── bgm.m4a                # Looping background music track
│
├── Assets.xcassets/           # App icon, accent color, all dish images
└── Package.swift              # Swift Playgrounds package manifest, iOS 18.1 target
```

---

## Framework Deep Dive

### SwiftUI
The entire UI layer — from the home screen to the collection detail view — is built with SwiftUI. The application takes full advantage of modern SwiftUI idioms: `@Observable` for zero-boilerplate state, `@Bindable` for two-way bindings into SwiftData models, `LazyVGrid` for performant recipe grids, `TimelineView` for live timer rendering without manual timers, and `withAnimation` blocks for fluid transitions between navigation states. Sheet presentations use `presentationDetents` for half-height contextual panels.

### ARKit
`ARWorldTrackingConfiguration` with `.horizontal` plane detection powers the surface scanning pipeline. The `ARCoachingOverlayView` is integrated and responds to tracking quality changes, automatically guiding users to improve their environment. Raycasting (`raycast(from:allowing:alignment:)`) drives both the placement reticle and the final content spawn. The coordinator observes `ARSessionDelegate` callbacks and manages the full lifecycle from scan to placement to cleanup.

### RealityKit
All 3D content is constructed entirely in code. `ModelEntity` objects are built from `MeshResource` and `UnlitMaterial` primitives. Text is rendered onto floating panels using `MeshResource.generateText` with configurable fonts, colors, and extrusion depths. `AnchorEntity(world:)` pins the entire kitchen to a specific real-world transform. `FromToByAnimation<Transform>` drives the pop-up scale animation when panels first appear, and a pulse animation provides tactile feedback on button taps. The `SceneEvents.Update` subscription loop handles timer bar updates and scale clamping at up to 60 times per second.

### SpriteKit
The puzzle engine is a fully custom `SKScene`. Piece shapes are defined as `CGMutablePath` triangular wedges and used as both visual borders and crop masks. Touch handling uses `touchesBegan`, `touchesMoved`, and `touchesEnded` for smooth drag interaction, with a subtle `zRotation` tilt on the dragged piece proportional to horizontal velocity. Snap detection uses Euclidean distance comparison against a configurable ratio of screen width, making the snap feel natural across all device sizes. A procedurally generated gradient texture provides the warm cream-to-brown background.

### SwiftData
`RecipeModel` is decorated with `@Model`, making it a full SwiftData entity. The `ModelContainer` is initialized at app startup and passed through the SwiftUI environment. `@Query` in `GalleryView` and `CollectionView` retrieves live data, automatically refreshing the UI on any model mutation. Puzzle state is encoded as a JSON string field on the model, allowing the entire piece configuration (position + locked status for each piece) to be saved and restored without a separate database table.

### NaturalLanguage
Apple's on-device NLP framework provides sentiment analysis with zero network dependency. `NLTagger` with the `.sentimentScore` scheme runs asynchronously on a detached task at `userInitiated` priority, ensuring the main thread is never blocked. The raw score is mapped deterministically to one of four emoji outcomes, which then drive both the collection categorization logic and the visual mood display in the detail view.

### AVFoundation & AudioToolbox
`AVAudioPlayer` manages the background music track with full interrupt handling conformance. `AudioToolbox`'s `AudioServicesPlaySystemSound` is used for precise haptic-style system sounds on specific interactions: panel placement (sound 1057), AR session reset (sound 1001), and step navigation (sound 1104).

---

## Data Model & Persistence

### RecipeModel (SwiftData Entity)

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier, auto-generated |
| `name` | `String` | Display name of the dessert |
| `imageName` | `String` | Asset catalog key for the dish image |
| `status` | `Int` | `0` = Not Started, `1` = In Progress, `2` = Served |
| `chosenColorHex` | `String` | Hex string for the recipe's accent color |
| `yield` | `String` | Output quantity (e.g., "12 Pieces") |
| `steps` | `[String]` | Ordered array of instruction text |
| `stepTimer` | `[Double]` | Per-step estimated durations in seconds |
| `ingredients` | `[String]` | Ingredient list for the AR panel |
| `userFeedback` | `String` | Free-text post-cook feedback |
| `emojiMood` | `String` | Sentiment-derived emoji moods based on user feedback |
| `puzzleStateJSON` | `String` | Serialized JSON of piece positions and lock states |

The computed property `col: Color` derives a SwiftUI color directly from `chosenColorHex`, making the recipe's color usable in views without any conversion boilerplate.

### Data Seeding Strategy

On first launch, `ChefApp` checks if `RecipeModel` count is zero. If so, it calls `DataSeeder.gen()`, which delegates to `RecipeDataService.loadRecipes()`. This function attempts to load from the bundled `Recipes.json` file first. If that fails for any reason, it falls back to a hardcoded JSON literal embedded in the source code. This guarantees that the database is always correctly populated on any first run, with no possibility of arriving at an empty state.

---

## Design System

The visual identity of the application is defined in two utility files and applied consistently across every screen.

### Color Palette (`Pal.swift`)

The palette is warm and culturally resonant. It draws from an earthy, artisanal spectrum — rich terracottas and deep carmines anchor the primary navigation surfaces, while warm creams and toasted browns compose the recipe browsing environment. Gilded accent tones are reserved for titles, highlights, and reward states, lending a sense of celebration to moments of achievement. A cool, electric accent is used sparingly in the AR and gamification layers to signal interactivity and contrast against the otherwise warm foundation. The AR panel system uses a near-opaque dark overlay with a luminous border, creating a distinct visual language that clearly separates virtual content from the physical world.

### Typography

Fonts are used semantically across the app:
- `.system(size: 80, weight: .black, design: .rounded)` — Home screen title for maximum visual impact
- `.largeTitle.bold()` — Section headers and primary labels
- `.headline` / `.subheadline` — Card labels and descriptors
- `.caption` / `.caption2.bold()` — Status badges and HUD labels
- `.system(...).monospacedDigit()` — Timer display for non-shifting numerals

### Layout Constants (`AppLayout`)

All spacing, corner radius, and icon size values are defined as named constants (`cornerSmall`, `cornerMed`, `cornerLarge`, `cornerXL`, `iconSmall`, `iconMed`, `iconLarge`, `hudHeight`), ensuring visual consistency and making global style changes a single-file operation.

### Localized String Management (`AppStrings`)

Every user-facing string is centralized in `AppStrings`, including all AR instruction copy, safety guidelines, button labels, toast messages, and placeholder text. This makes the app straightforward to localize and ensures no string literals are scattered across view files.

---

## Requirements

| Requirement | Detail |
|-------------|--------|
| **Platform** | iOS 18.1 or later |
| **Device** | iPad |
| **Camera** | Required for AR plane detection and world tracking |
| **Development Environment** | Swift Playgrounds 4 or Xcode 16 |
| **External Dependencies** | None — all frameworks are Apple-native |
| **Network** | Not required — fully offline |

The app requests camera access at the point of entering the AR session with a clear purpose string: *"This app uses camera to visualise the physical environment for placing and interacting with recipe panels in the real world."* No other permissions are requested at any point during the user experience.

---

## About

This project was conceived and built as an exploration of what an interactive cultural education experience could look like when augmented reality, gamification, and on-device machine learning are treated not as features, but as the primary medium of storytelling. Bengali sweets were chosen not merely as content, but as a lens through which to demonstrate that spatial computing can make the richness of culinary tradition feel genuinely alive and present.