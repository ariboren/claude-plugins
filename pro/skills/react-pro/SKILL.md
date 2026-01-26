---
name: react-pro
description: React 18+ expertise for modern patterns, performance optimization, server components, and production architectures. Use when building React applications, optimizing renders, or implementing advanced patterns.
---

# React Expertise

## React 18+ Features

Concurrent Features:

- `useTransition` for non-blocking updates
- `useDeferredValue` for expensive computations
- Automatic batching for all updates
- `<Suspense>` for data fetching
- Server Components for zero-bundle components

## Performance Optimization

### Preventing Unnecessary Renders

```tsx
// Memoize expensive computations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items],
);

// Memoize callbacks passed to children
const handleClick = useCallback(
  (id: string) => dispatch({ type: "SELECT", id }),
  [dispatch],
);

// Memoize components
const MemoizedChild = memo(Child);
```

### React.memo Correctly

```tsx
// Only memoize when props are stable or comparison is cheap
const ListItem = memo(function ListItem({ item, onSelect }) {
  return <div onClick={() => onSelect(item.id)}>{item.name}</div>;
});

// Custom comparison for complex props
const Chart = memo(ChartComponent, (prev, next) => {
  return (
    prev.data.length === next.data.length &&
    prev.data.every((d, i) => d.value === next.data[i].value)
  );
});
```

### useTransition for Heavy Updates

```tsx
function SearchResults() {
  const [query, setQuery] = useState("");
  const [isPending, startTransition] = useTransition();

  const handleChange = (e) => {
    // Urgent: update input immediately
    setQuery(e.target.value);

    // Non-urgent: filter results can wait
    startTransition(() => {
      setFilteredResults(filterResults(e.target.value));
    });
  };

  return (
    <>
      <input value={query} onChange={handleChange} />
      {isPending && <Spinner />}
      <Results data={filteredResults} />
    </>
  );
}
```

## State Management

### When to Use What

| Solution       | Use Case                           |
| -------------- | ---------------------------------- |
| useState       | Local component state              |
| useReducer     | Complex state logic                |
| Context        | Infrequently changing shared state |
| Zustand/Jotai  | Frequently changing global state   |
| TanStack Query | Server state / caching             |

### Context Optimization

```tsx
// Split contexts to prevent unnecessary renders
const UserContext = createContext(null);
const UserDispatchContext = createContext(null);

function UserProvider({ children }) {
  const [user, dispatch] = useReducer(userReducer, null);

  return (
    <UserContext.Provider value={user}>
      <UserDispatchContext.Provider value={dispatch}>
        {children}
      </UserDispatchContext.Provider>
    </UserContext.Provider>
  );
}
```

## Advanced Patterns

### Compound Components

```tsx
function Tabs({ children, defaultValue }) {
  const [active, setActive] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ active, setActive }}>
      {children}
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }) {
  /* ... */
};
Tabs.Tab = function Tab({ value, children }) {
  /* ... */
};
Tabs.Panel = function TabsPanel({ value, children }) {
  /* ... */
};

// Usage
<Tabs defaultValue="tab1">
  <Tabs.List>
    <Tabs.Tab value="tab1">First</Tabs.Tab>
    <Tabs.Tab value="tab2">Second</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="tab1">Content 1</Tabs.Panel>
  <Tabs.Panel value="tab2">Content 2</Tabs.Panel>
</Tabs>;
```

### Render Props

```tsx
function MouseTracker({ render }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handler = (e) => setPosition({ x: e.clientX, y: e.clientY });
    window.addEventListener("mousemove", handler);
    return () => window.removeEventListener("mousemove", handler);
  }, []);

  return render(position);
}

// Usage
<MouseTracker render={({ x, y }) => <Tooltip x={x} y={y} />} />;
```

### Custom Hooks

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

## Error Handling

### Error Boundaries

```tsx
class ErrorBoundary extends Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

## Server Components (Next.js 13+)

```tsx
// Server Component (default)
async function ProductList() {
  const products = await db.products.findMany();
  return products.map((p) => <ProductCard key={p.id} product={p} />);
}

// Client Component (needs interactivity)
("use client");
function AddToCartButton({ productId }) {
  const [pending, startTransition] = useTransition();

  return (
    <button onClick={() => startTransition(() => addToCart(productId))}>
      {pending ? "Adding..." : "Add to Cart"}
    </button>
  );
}
```

## Testing

### React Testing Library

```tsx
import { render, screen, userEvent } from "@testing-library/react";

test("submits form with user data", async () => {
  const onSubmit = jest.fn();
  render(<UserForm onSubmit={onSubmit} />);

  await userEvent.type(screen.getByLabelText(/name/i), "John");
  await userEvent.type(screen.getByLabelText(/email/i), "john@example.com");
  await userEvent.click(screen.getByRole("button", { name: /submit/i }));

  expect(onSubmit).toHaveBeenCalledWith({
    name: "John",
    email: "john@example.com",
  });
});
```

## Quality Checklist

- [ ] React 18+ features utilized effectively
- [ ] TypeScript strict mode enabled
- [ ] Component reusability > 80% achieved
- [ ] Performance score > 95 maintained
- [ ] Test coverage > 90% implemented
- [ ] Bundle size optimized thoroughly
- [ ] Accessibility compliant consistently
- [ ] Best practices followed completely
