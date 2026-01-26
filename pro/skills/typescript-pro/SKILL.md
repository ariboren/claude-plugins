---
name: typescript-pro
description: TypeScript expertise for advanced type system usage, full-stack type safety, and build optimization. Use when working with TypeScript, implementing type-safe patterns, or optimizing builds.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# TypeScript Expertise

## Advanced Types

### Conditional Types

```typescript
// Extract return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// Exclude null/undefined
type NonNullable<T> = T extends null | undefined ? never : T;

// Distributive conditional
type ToArray<T> = T extends any ? T[] : never;
type Result = ToArray<string | number>; // string[] | number[]
```

### Mapped Types

```typescript
// Make all properties optional
type Partial<T> = {
  [P in keyof T]?: T[P];
};

// Make all properties readonly
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

// Pick specific properties
type Pick<T, K extends keyof T> = {
  [P in K]: T[P];
};

// Transform property types
type Stringify<T> = {
  [K in keyof T]: string;
};
```

### Template Literal Types

```typescript
type EventName<T extends string> = `on${Capitalize<T>}`;
type ClickEvent = EventName<"click">; // 'onClick'

type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}
type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number; }
```

### Branded Types

```typescript
// Prevent mixing up similar types
type UserId = string & { readonly brand: unique symbol };
type OrderId = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
    return id as UserId;
}

function getUser(id: UserId): User { ... }

const userId = createUserId('123');
const orderId = '456' as OrderId;

getUser(userId);   // ✓
getUser(orderId);  // ✗ Type error
```

## Type Guards

### Custom Type Guards

```typescript
interface Dog {
  bark(): void;
}
interface Cat {
  meow(): void;
}

function isDog(pet: Dog | Cat): pet is Dog {
  return "bark" in pet;
}

function speak(pet: Dog | Cat) {
  if (isDog(pet)) {
    pet.bark(); // TypeScript knows it's Dog
  } else {
    pet.meow(); // TypeScript knows it's Cat
  }
}
```

### Discriminated Unions

```typescript
type Result<T> = { success: true; data: T } | { success: false; error: Error };

function handle<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // data is available
  } else {
    console.log(result.error); // error is available
  }
}
```

## Full-Stack Type Safety

### tRPC Pattern

```typescript
// Server
const appRouter = router({
  user: router({
    get: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => {
        return getUserById(input.id);
      }),
  }),
});

export type AppRouter = typeof appRouter;

// Client - fully typed!
const user = await trpc.user.get.query({ id: "123" });
```

### Zod Validation

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
});

type User = z.infer<typeof UserSchema>;

// Runtime validation + TypeScript type
function createUser(input: unknown): User {
  return UserSchema.parse(input);
}
```

## Utility Patterns

### Type-Safe Event Emitter

```typescript
type EventMap = {
  userLogin: { userId: string; timestamp: Date };
  userLogout: { userId: string };
  error: { message: string; code: number };
};

class TypedEventEmitter<T extends Record<string, any>> {
  private handlers = new Map<keyof T, Set<Function>>();

  on<K extends keyof T>(event: K, handler: (data: T[K]) => void) {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    this.handlers.get(event)!.add(handler);
  }

  emit<K extends keyof T>(event: K, data: T[K]) {
    this.handlers.get(event)?.forEach((h) => h(data));
  }
}

const emitter = new TypedEventEmitter<EventMap>();
emitter.on("userLogin", (data) => {
  console.log(data.userId); // typed!
});
```

### Builder Pattern

```typescript
class QueryBuilder<T extends object = {}> {
  private query: Partial<T> = {};

  where<K extends string, V>(key: K, value: V): QueryBuilder<T & Record<K, V>> {
    (this.query as any)[key] = value;
    return this as any;
  }

  build(): T {
    return this.query as T;
  }
}

const query = new QueryBuilder().where("name", "John").where("age", 30).build();
// Type: { name: string; age: number }
```

## Performance

### Type-Only Imports

```typescript
// Only import the type (removed at runtime)
import type { User } from "./types";

// Import both type and value
import { User, createUser } from "./user";
```

### Const Assertions

```typescript
// Without as const
const routes = {
  home: "/",
  about: "/about",
}; // { home: string; about: string }

// With as const
const routes = {
  home: "/",
  about: "/about",
} as const; // { readonly home: '/'; readonly about: '/about' }

type Route = (typeof routes)[keyof typeof routes]; // '/' | '/about'
```

## Configuration

### Strict tsconfig

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true
  }
}
```

## Quality Checklist

- [ ] Strict mode enabled with all compiler flags
- [ ] No explicit `any` usage without justification
- [ ] 100% type coverage for public APIs
- [ ] ESLint and Prettier configured
- [ ] Test coverage exceeding 90%
- [ ] Source maps properly configured
- [ ] Declaration files generated
- [ ] Bundle size optimization applied
