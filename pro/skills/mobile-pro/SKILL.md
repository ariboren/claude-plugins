---
name: mobile-pro
description: Mobile app development expertise for iOS and Android, native and cross-platform frameworks, performance optimization, and platform guidelines. Use when building mobile apps, optimizing performance, or implementing platform-specific features.
---

# Mobile Development Expertise

## Performance Targets

- App size < 50MB
- Startup time < 2 seconds
- Crash rate < 0.1%
- Battery usage optimized
- Memory within platform limits
- Offline capability where needed

## Native iOS Development

### Swift/SwiftUI

```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items) { item in
            ItemRow(item: item)
        }
        .task {
            items = await fetchItems()
        }
    }
}
```

Key Patterns:

- SwiftUI for declarative UI
- Combine for reactive data flow
- async/await for concurrency
- Core Data or SwiftData for persistence
- CloudKit for sync

## Native Android Development

### Kotlin/Jetpack Compose

```kotlin
@Composable
fun ItemList(viewModel: ItemViewModel = viewModel()) {
    val items by viewModel.items.collectAsState()

    LazyColumn {
        items(items) { item ->
            ItemRow(item = item)
        }
    }
}
```

Key Patterns:

- Jetpack Compose for UI
- Kotlin Flow for reactive data
- Room for local database
- WorkManager for background tasks
- DataStore for preferences

## Cross-Platform Considerations

Framework Selection:

- React Native: Large ecosystem, JavaScript skills
- Flutter: High performance, Dart language
- Expo: Rapid development, managed workflow

Shared Code Strategy:

- Business logic in shared layer
- Platform-specific UI when needed
- Native modules for performance-critical features

## Performance Optimization

### Launch Time

- Defer non-critical initialization
- Use lazy loading for screens
- Optimize main thread work
- Profile with native tools (Instruments, Android Profiler)

### Memory Management

- Use weak references appropriately
- Clean up observers and listeners
- Implement proper caching with limits
- Profile memory usage regularly

### Battery Efficiency

- Batch network requests
- Use efficient location tracking
- Minimize background work
- Respect system power states

## Offline Functionality

### Data Sync Strategy

```
Local Database ←→ Sync Queue ←→ Server

1. Write to local DB immediately
2. Queue changes for sync
3. Sync when network available
4. Handle conflicts
```

Conflict Resolution:

- Last-write-wins for simple cases
- Merge strategies for complex data
- User intervention for critical conflicts

### Cache Management

- Cache responses with TTL
- Implement cache invalidation
- Offline-first for critical paths
- Background sync when possible

## Push Notifications

### Implementation

iOS (APNS):

```swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
```

Android (FCM):

```kotlin
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    if (task.isSuccessful) {
        val token = task.result
        sendTokenToServer(token)
    }
}
```

Best Practices:

- Request permission contextually
- Handle notification tap navigation
- Support rich notifications
- Track notification analytics

## Device Integration

### Biometric Authentication

```swift
// iOS
let context = LAContext()
context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock app")
```

```kotlin
// Android
val biometricPrompt = BiometricPrompt(activity, executor, callback)
biometricPrompt.authenticate(promptInfo)
```

### Camera Access

- Request permissions contextually
- Handle permission denial gracefully
- Support multiple camera modes
- Optimize for memory usage

## App Store Optimization

Metadata:

- Keyword-rich title and subtitle
- Compelling description with keywords
- High-quality screenshots
- Preview videos for key features

Performance:

- Fast app review with small updates
- A/B test store listing
- Respond to reviews
- Monitor ratings and feedback

## Security Implementation

Data Protection:

- Use Keychain (iOS) / Keystore (Android) for secrets
- Encrypt sensitive local data
- Certificate pinning for API calls
- Obfuscate sensitive code

Authentication:

- Support biometric login
- Implement secure session management
- Handle token refresh properly
- Support SSO where appropriate

## Testing Strategy

Levels:

- Unit tests for business logic
- Widget/UI tests for components
- Integration tests for flows
- E2E tests for critical paths

Device Testing:

- Test on real devices
- Cover range of OS versions
- Test different screen sizes
- Test offline scenarios

## CI/CD Pipeline

Build Automation:

- Automated builds on commit
- Code signing management
- Beta distribution (TestFlight, Firebase)
- Automated store submission

Quality Gates:

- Lint checks
- Unit test coverage
- UI test suite
- Performance benchmarks

## Quality Checklist

- [ ] App size < 50MB achieved
- [ ] Startup time < 2 seconds
- [ ] Crash rate < 0.1% maintained
- [ ] Battery usage efficient
- [ ] Memory usage optimized
- [ ] Offline capability enabled
- [ ] Accessibility compliant
- [ ] Store guidelines met
