---
name: javascript-pro
description: Modern JavaScript ES2023+ expertise for asynchronous programming, functional patterns, and full-stack development. Use when writing JavaScript, optimizing performance, or working with Node.js and browser APIs.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# JavaScript Expertise

## Modern JavaScript (ES2023+)

Essential Features:

- Optional chaining (`?.`) and nullish coalescing (`??`)
- Private class fields (`#privateField`)
- Top-level await in modules
- Array methods: `at()`, `findLast()`, `toSorted()`, `toReversed()`
- Object.hasOwn() over hasOwnProperty
- WeakRef and FinalizationRegistry for advanced memory
- Dynamic imports for code splitting

## Asynchronous Patterns

### Async/Await Best Practices

```javascript
// Good: Concurrent execution
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);

// Bad: Sequential when not needed
const users = await fetchUsers();
const posts = await fetchPosts();
```

### Error Handling

```javascript
// Wrap async operations
async function fetchData() {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  } catch (error) {
    if (error.name === "AbortError") return null;
    throw error;
  }
}
```

### Promise Patterns

```javascript
// Promise.allSettled for handling mixed results
const results = await Promise.allSettled(promises);
const fulfilled = results.filter((r) => r.status === "fulfilled");
const rejected = results.filter((r) => r.status === "rejected");

// AbortController for cancellation
const controller = new AbortController();
fetch(url, { signal: controller.signal });
controller.abort();
```

## Functional Programming

Higher-Order Functions:

```javascript
// Composition
const compose =
  (...fns) =>
  (x) =>
    fns.reduceRight((acc, fn) => fn(acc), x);
const pipe =
  (...fns) =>
  (x) =>
    fns.reduce((acc, fn) => fn(acc), x);

// Currying
const curry =
  (fn) =>
  (...args) =>
    args.length >= fn.length ? fn(...args) : curry(fn.bind(null, ...args));
```

Immutability Patterns:

```javascript
// Array operations (non-mutating)
const added = [...array, newItem];
const removed = array.filter((_, i) => i !== index);
const updated = array.map((item, i) => (i === index ? newItem : item));

// Object operations
const updated = { ...obj, key: newValue };
const { removed, ...rest } = obj;
```

## Performance Optimization

### Memory Management

```javascript
// Use WeakMap for object metadata
const metadata = new WeakMap();
metadata.set(obj, { created: Date.now() });

// Clean up event listeners
const controller = new AbortController();
element.addEventListener("click", handler, { signal: controller.signal });
// Later: controller.abort() removes all listeners
```

### Debouncing and Throttling

```javascript
function debounce(fn, ms) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), ms);
  };
}

function throttle(fn, ms) {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= ms) {
      lastCall = now;
      fn(...args);
    }
  };
}
```

### Web Workers

```javascript
// Main thread
const worker = new Worker("worker.js");
worker.postMessage({ data });
worker.onmessage = (e) => console.log(e.data);

// Worker thread (worker.js)
self.onmessage = (e) => {
  const result = heavyComputation(e.data);
  self.postMessage(result);
};
```

## Node.js Patterns

### Streams

```javascript
import { pipeline } from "stream/promises";
import { createReadStream, createWriteStream } from "fs";
import { createGzip } from "zlib";

await pipeline(
  createReadStream("input.txt"),
  createGzip(),
  createWriteStream("output.txt.gz"),
);
```

### Error-First Callbacks to Promises

```javascript
import { promisify } from "util";
const readFile = promisify(fs.readFile);

// Or use fs/promises directly
import { readFile } from "fs/promises";
```

## Browser APIs

### Intersection Observer

```javascript
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        loadImage(entry.target);
        observer.unobserve(entry.target);
      }
    });
  },
  { rootMargin: "100px" },
);

images.forEach((img) => observer.observe(img));
```

### Fetch with Timeout

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeout);

  try {
    return await fetch(url, { ...options, signal: controller.signal });
  } finally {
    clearTimeout(id);
  }
}
```

## Module Patterns

### ESM Best Practices

```javascript
// Named exports preferred
export { fetchUser, createUser };

// Re-exports
export { default as Button } from "./Button.js";
export * from "./utils.js";

// Dynamic imports
const module = await import(`./locales/${lang}.js`);
```

### Avoiding Barrel File Issues

```javascript
// Bad: barrel imports pull entire module
import { helper } from "./utils"; // utils/index.js exports everything

// Good: direct imports
import { helper } from "./utils/helper.js";
```

## Testing

### Jest Patterns

```javascript
describe("fetchUser", () => {
  it("returns user data", async () => {
    const user = await fetchUser(1);
    expect(user).toMatchObject({ id: 1, name: expect.any(String) });
  });

  it("throws on network error", async () => {
    jest.spyOn(global, "fetch").mockRejectedValueOnce(new Error("Network"));
    await expect(fetchUser(1)).rejects.toThrow("Network");
  });
});
```

## Security Practices

Input Validation:

```javascript
// Sanitize HTML
const sanitized = DOMPurify.sanitize(userInput);

// Validate URLs
function isValidUrl(string) {
  try {
    const url = new URL(string);
    return ["http:", "https:"].includes(url.protocol);
  } catch {
    return false;
  }
}
```

## Quality Checklist

- [ ] ESLint with strict configuration
- [ ] Prettier formatting applied
- [ ] Test coverage exceeding 85%
- [ ] JSDoc documentation complete
- [ ] Bundle size optimized
- [ ] Security vulnerabilities checked
- [ ] Cross-browser compatibility verified
- [ ] Performance benchmarks established
