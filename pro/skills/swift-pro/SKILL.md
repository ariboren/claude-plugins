---
name: swift-pro
description: Swift 5.9+ expertise for async/await, SwiftUI, protocol-oriented programming, and Apple platform development. Use when building iOS/macOS apps, implementing Swift patterns, or optimizing performance.
---

# Swift Expertise

## Modern Swift Patterns

### Async/Await

```swift
// Concurrent execution
async let users = fetchUsers()
async let posts = fetchPosts()
let (userList, postList) = await (users, posts)

// Task groups for dynamic concurrency
let results = await withTaskGroup(of: Data?.self) { group in
    for url in urls {
        group.addTask { await fetchData(from: url) }
    }

    var collected: [Data] = []
    for await result in group {
        if let data = result { collected.append(data) }
    }
    return collected
}
```

### Actors

```swift
actor BankAccount {
    private var balance: Decimal = 0

    func deposit(_ amount: Decimal) {
        balance += amount
    }

    func withdraw(_ amount: Decimal) throws -> Decimal {
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        balance -= amount
        return amount
    }
}

// Usage (automatically serialized)
await account.deposit(100)
let withdrawn = try await account.withdraw(50)
```

### Structured Concurrency

```swift
// Task cancellation propagates automatically
func fetchAllData() async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for url in urls {
            group.addTask {
                // If parent task cancels, these cancel too
                try await fetchData(url)
            }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}
```

## SwiftUI Patterns

### State Management

```swift
struct ContentView: View {
    @State private var count = 0           // Local state
    @StateObject private var vm = ViewModel()  // Owned object
    @ObservedObject var model: Model       // Passed object
    @EnvironmentObject var settings: Settings  // Injected

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
        }
    }
}
```

### Custom ViewModifiers

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Hello").cardStyle()
```

### Property Wrappers

```swift
@propertyWrapper
struct Clamped<Value: Comparable> {
    var value: Value
    let range: ClosedRange<Value>

    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct Settings {
    @Clamped(0...100) var volume: Int = 50
}
```

## Protocol-Oriented Design

### Protocol Composition

```swift
protocol Identifiable {
    var id: UUID { get }
}

protocol Timestamped {
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

// Compose protocols
typealias Entity = Identifiable & Timestamped

struct User: Entity {
    let id: UUID
    let createdAt: Date
    var updatedAt: Date
}
```

### Protocol Extensions

```swift
protocol DataFetcher {
    associatedtype Output
    func fetch() async throws -> Output
}

extension DataFetcher {
    // Default implementation with retry
    func fetchWithRetry(attempts: Int = 3) async throws -> Output {
        var lastError: Error?
        for _ in 0..<attempts {
            do {
                return try await fetch()
            } catch {
                lastError = error
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        throw lastError!
    }
}
```

## Error Handling

### Result Type

```swift
enum NetworkError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
}

func fetchUser(id: Int) async -> Result<User, NetworkError> {
    guard let url = URL(string: "https://api.example.com/users/\(id)") else {
        return .failure(.invalidURL)
    }

    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            return .failure(.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0))
        }
        let user = try JSONDecoder().decode(User.self, from: data)
        return .success(user)
    } catch let error as DecodingError {
        return .failure(.decodingFailed(error))
    } catch {
        return .failure(.requestFailed(statusCode: 0))
    }
}
```

## Memory Management

### Capture Lists

```swift
class ViewController {
    var handler: (() -> Void)?

    func setupHandler() {
        // Weak capture to avoid retain cycle
        handler = { [weak self] in
            guard let self else { return }
            self.doSomething()
        }
    }
}
```

### Value Semantics

```swift
// Prefer structs for data types
struct Point {
    var x: Double
    var y: Double
}

// Copy-on-write for efficient large value types
struct LargeData {
    private var storage: Storage

    mutating func modify() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
        // Now safe to modify
    }
}
```

## Testing

### Async Testing

```swift
func testFetchUser() async throws {
    let service = UserService()
    let user = try await service.fetchUser(id: 1)

    XCTAssertEqual(user.id, 1)
    XCTAssertEqual(user.name, "John")
}
```

### Dependency Injection for Testing

```swift
protocol APIClient {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
}

class UserService {
    let client: APIClient

    init(client: APIClient = RealAPIClient()) {
        self.client = client
    }
}

// In tests
class MockAPIClient: APIClient {
    var mockResponse: Any?

    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        return mockResponse as! T
    }
}
```

## Quality Checklist

- [ ] SwiftLint strict mode compliance
- [ ] 100% API documentation
- [ ] Test coverage exceeding 80%
- [ ] Instruments profiling clean
- [ ] Thread safety verification
- [ ] Sendable compliance checked
- [ ] Memory leak free
- [ ] API design guidelines followed
