---
name: react-native-patterns
description: Apply repository-aware React Native patterns for mobile app implementation, review, accessibility, navigation, native integrations, Metro issues, and Android or iOS behavior. Use for Expo and bare React Native apps; use react-patterns for React DOM web applications.
---

# React Native Patterns

Build mobile UI around native platform behavior and the conventions already used by the app. React Native APIs, Expo capabilities, architecture support, and library compatibility vary by project version; inspect the repository before choosing an approach.

## References

Use the official documentation for the installed versions when platform or API details matter:

- React Native accessibility: https://reactnative.dev/docs/accessibility
- React Native testing overview: https://reactnative.dev/docs/testing-overview
- React Native performance: https://reactnative.dev/docs/performance
- Expo development workflow: https://docs.expo.dev/workflow/overview/
- Expo custom native code: https://docs.expo.dev/workflow/customizing/

## Project Orientation

Before changing code, inspect:

- `package.json`, lockfile, React Native and Expo versions, package-manager scripts, and workspace layout.
- Whether the project uses Expo tooling, Continuous Native Generation (CNG), a bare React Native CLI setup, or a mixed/brownfield integration.
- Whether `ios/` and `android/` are tracked, generated, or absent; native project state is part of the ownership contract.
- Navigation, styling, state/data, localization, permissions, test, lint, and build conventions already in use.
- The app's minimum OS versions, supported devices, and native modules when the task touches platform code.

Do not assume Expo, Expo Router, React Navigation, the New Architecture, or a particular native library is present. Do not run prebuild, regenerate native projects, change native configuration, or add a package without a task reason and authorization appropriate to that change. Never use `prebuild --clean` as routine troubleshooting; first establish how the repository manages native projects and preserve local native changes.

## Components, Layout, and State

- Use React Native primitives (`View`, `Text`, `Pressable`, `TextInput`, and list components) and the project's shared components. Do not use DOM elements, browser APIs, CSS files, or web-only ARIA patterns in native screens.
- Use `StyleSheet` or the existing styling system. Account for flexbox differences, density-independent dimensions, safe areas, font scaling, orientation, and small or large screens.
- Model platform differences deliberately with `Platform` or platform-specific files only when behavior or native capability actually differs. Keep product logic shared where it remains clear.
- Keep render pure, follow the Rules of Hooks, derive values rather than duplicating state, and clean up subscriptions, timers, listeners, and async work.
- Handle app lifecycle and navigation focus when refreshing screen data, subscriptions, or device resources. Avoid assuming a mounted screen is visible or the app is foregrounded.
- For long or changing data, follow existing list patterns and use `FlatList` or `SectionList` where virtualization is needed. Use stable keys and measure before tuning batching, windowing, memoization, or image loading.
- Handle keyboard, focus, back navigation, gestures, status/navigation bars, deep links, and permissions in the project's existing navigation and platform conventions.

## Native Capabilities and Builds

- Inspect library compatibility with the installed React Native/Expo versions, target platforms, and current architecture before adding or upgrading native dependencies.
- Distinguish JavaScript-only changes from changes that require a new native build. When using Expo, check whether the app runs in Expo Go or a development build and whether a config plugin or native project edit is required.
- Treat `ios/`, `android/`, app configuration, entitlements, manifests, signing, permissions, and generated native code as high-impact project state. Preserve manual edits and do not overwrite or regenerate them casually.
- For native modules or platform-specific code, inspect the bridge/module pattern already used in the repository and keep platform behavior and error handling explicit.
- Reproduce Metro, Gradle, Xcode, CocoaPods, or runtime failures with the narrowest repository-configured command. Do not reset Metro caches, reinstall pods, clean native build directories, or regenerate lockfiles unless evidence points there.

## Accessibility and Interaction

- Give controls meaningful labels, roles, and state using the React Native accessibility APIs supported by the project's version. Check the actual VoiceOver and TalkBack behavior for important flows.
- Preserve logical screen-reader focus order and avoid hiding focusable content. Announce important dynamic state changes without making every update interruptive.
- Support touch target usability, text scaling, contrast, reduced motion where relevant, and clear focused, selected, disabled, loading, and error states.
- Check keyboard and hardware-input behavior when the app supports tablets, external keyboards, or accessibility switch controls.
- Use the `accessibility` skill for shared principles when useful, but apply native APIs and platform-specific behavior here rather than web DOM/ARIA instructions.

## Testing and Performance

- Inspect the repository's test setup first. Use its existing Jest and React Native Testing Library patterns for user-visible component behavior; use its established device or E2E tooling for native integration flows.
- Keep unit/component tests deterministic and focused. Mock device or native module boundaries using existing project helpers; do not replace meaningful integration behavior with excessive mocks.
- Test platform-specific behavior on the relevant OS or simulator/emulator when the risk cannot be represented by a JavaScript component test.
- Diagnose performance in a production-like build when appropriate. Separate JavaScript-thread work from UI/native-thread work, measure before optimizing, and check list rendering, images, unnecessary updates, and startup/navigation costs.
- Run the narrowest configured typecheck, lint, test, Metro, and native build checks relevant to the change. Report platform checks that could not run in the current environment.

## Routing and Review

- Use `typescript-patterns` for TypeScript boundaries and type design.
- Use `react-testing` only for web DOM tests; this skill owns React Native Testing Library and device-test routing.
- Use `frontend-build-resolver` only for web frontend failures. Diagnose Metro and native build failures using this skill and the repository's configured tools.
- For React Native reviews, prioritize user-visible behavior on both platforms, lifecycle and permission handling, native dependency compatibility, accessibility, navigation and back behavior, data races, and whether native project changes are reproducible.
- Avoid platform checks, native abstractions, third-party packages, or performance tuning that do not address a concrete requirement.
