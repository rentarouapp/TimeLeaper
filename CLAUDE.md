# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build
xcodebuild -project TimeLeaper.xcodeproj -scheme TimeLeaper -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests
xcodebuild -project TimeLeaper.xcodeproj -scheme TimeLeaper -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run UI tests
xcodebuild -project TimeLeaper.xcodeproj -scheme TimeLeaper -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TimeLeaperUITests test

# Open in Xcode
open TimeLeaper.xcodeproj
```

No linting tools are configured. No external package dependencies.

## Architecture

TimeLeaper is an iOS 18+ app comparing the same book-search feature implemented in three paradigms: Objective-C (functional), Swift (placeholder), and SwiftUI (placeholder). It uses the Google Books API (`https://www.googleapis.com/books/v1/volumes`).

### Entry point and navigation

`TimeLeaperApp.swift` → `BaseView.swift` (TabView with 3 tabs: Objc / Swift / SwiftUI)

### Objective-C tab flow

```
ObjcBaseView (SwiftUI wrapper)
  → ListObjcVCView (UIViewControllerRepresentable, wraps in UINavigationController)
    → ListObjcViewController (UITableViewController + UISearchBar)
      → ItemService (singleton) → APIClient (singleton, NSURLSession)
      → DetailObjcViewController → SFSafariViewController
```

### Layer responsibilities

- **Views/** — SwiftUI views and UIViewControllerRepresentable bridges. Bridging header at `Views/TimeLeaper-Bridging-Header.h`.
- **Controllers/Objective-C/** — UIKit view controllers (programmatic layout, no storyboards).
- **Services/Objective-C/** — `APIClient` (generic HTTP GET client), `ItemService` (Google Books query + JSON→BookItem parsing).
- **Models/Objective-C/** — `BookItem` (read-only properties, initialized from API dictionary).

### Key patterns

- Singletons via `+(instancetype)sharedService` / `sharedClient` with `dispatch_once`
- Block-based completion handlers (typedef'd as `ItemServiceCompletion`, `APIClientCompletion`)
- `dispatch_async(dispatch_get_main_queue(), ...)` for UI updates from network callbacks
- NSError with custom domains (`ItemServiceErrorDomain`, `APIClientErrorDomain`)
- UI text is in Japanese (e.g. "本を探す", "本の詳細")

## Language interop

Swift calls Objective-C through the bridging header. When adding new Objective-C headers that Swift needs to access, import them in `TimeLeaper-Bridging-Header.h`.
