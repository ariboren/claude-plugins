---
name: root-cause-analyzer
description: Debugging expertise for systematic investigation, root cause identification, and comprehensive analysis. Use when investigating bugs, errors, unexpected behavior, or test failures.
allowed-tools: Glob, Grep, Read, WebFetch, TodoWrite, WebSearch, Skill
---

# Root Cause Analysis Expertise

## Investigation Methodology

### 1. Reproduce Mentally

First, understand exactly what the user is experiencing:

- What is the expected behavior?
- What is the actual behavior?
- When does it occur? (Always, sometimes, specific conditions)
- What changed recently?

### 2. Trace Backwards

Starting from the symptom, work backwards through:

- Call stack and execution path
- Data flow and state changes
- Recent code changes
- Environmental factors

### 3. Distinguish Root vs Symptom

| Level           | Example                                                           |
| --------------- | ----------------------------------------------------------------- |
| Symptom         | "TypeError: Cannot read property 'map' of undefined"              |
| Proximate Cause | `items` is undefined when `items.map()` is called                 |
| Root Cause      | Query returns undefined before data loads, no loading state check |

## Common Bug Patterns

### React/React Native

**Stale Closure**

```typescript
// Bug: handler captures stale value
useEffect(() => {
  const handler = () => console.log(count); // stale!
  window.addEventListener("click", handler);
  return () => window.removeEventListener("click", handler);
}, []); // missing count dependency

// Fix: include all dependencies
useEffect(() => {
  const handler = () => console.log(count);
  window.addEventListener("click", handler);
  return () => window.removeEventListener("click", handler);
}, [count]);
```

**Missing Dependency**

```typescript
// Bug: effect doesn't run when userId changes
useEffect(() => {
  fetchUser(userId);
}, []); // should include userId
```

**Race Condition**

```typescript
// Bug: old request finishes after new one
useEffect(() => {
  fetchData(id).then(setData);
}, [id]);

// Fix: abort stale requests
useEffect(() => {
  const controller = new AbortController();
  fetchData(id, { signal: controller.signal }).then(setData);
  return () => controller.abort();
}, [id]);
```

### TanStack Query

**Query Key Mismatch**

```typescript
// Bug: invalidation doesn't work
useQuery({ queryKey: ['user', id], ... });
queryClient.invalidateQueries({ queryKey: ['users'] }); // wrong key!
```

**Stale Closure in Mutation**

```typescript
// Bug: onSuccess uses stale values
const mutation = useMutation({
  onSuccess: () => {
    // This closes over stale state!
    console.log(currentState);
  },
});

// Fix: use callback form or ref
const mutation = useMutation({
  onSuccess: (data, variables, context) => {
    // Use data/variables/context instead
  },
});
```

### Async/Promises

**Unhandled Rejection**

```typescript
// Bug: error silently swallowed
async function fetchData() {
  const response = await fetch(url); // throws on network error
  return response.json();
}

// Fix: handle errors
async function fetchData() {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  } catch (error) {
    console.error("Fetch failed:", error);
    throw error;
  }
}
```

**Promise.all Partial Failure**

```typescript
// Bug: all-or-nothing failure
const results = await Promise.all(requests);

// Fix: handle partial success
const results = await Promise.allSettled(requests);
const successes = results.filter((r) => r.status === "fulfilled");
const failures = results.filter((r) => r.status === "rejected");
```

### TypeScript

**Type Assertion Hiding Bugs**

```typescript
// Bug: assertion bypasses type checking
const user = response.data as User; // might not be User!

// Fix: validate at runtime
const user = validateUser(response.data);
```

**Null/Undefined Confusion**

```typescript
// Bug: checking wrong falsy value
if (!user) {
  // triggers for null, undefined, '', 0, false
  return;
}

// Fix: explicit check
if (user === null || user === undefined) {
  return;
}
```

## Output Format

### Issue Summary

[One-sentence description of what's broken]

### Observed Behavior

[What actually happens, including error messages]

### Expected Behavior

[What should happen instead]

### Root Cause

[The fundamental reason this issue exists]

### Technical Analysis

[Detailed explanation with file paths, line numbers, code paths]

### Chain of Causation

1. [Initial trigger]
2. [Intermediate step]
3. [Final symptom]

### Contributing Factors

[Secondary issues that enabled or worsened the problem]

### Recommended Fix

[Specific code changes to resolve the issue]

### Verification Steps

[How to confirm the diagnosis and fix]

## Debugging Tools

### React DevTools

- Component tree inspection
- Props and state examination
- Profiler for performance
- Highlight updates

### Chrome DevTools

- Network tab for API calls
- Console for errors
- Performance tab for bottlenecks
- Memory tab for leaks

### Logging Strategy

```typescript
// Structured logging for debugging
console.log("[ComponentName]", {
  action: "fetchData",
  input: { id },
  result: data,
  timestamp: Date.now(),
});
```

## Quality Standards

- Analysis must be specific enough to implement fix without additional investigation
- Include file paths, function names, and code snippets
- If multiple potential causes exist, rank by likelihood
- Never guess—clearly state what additional context is needed
