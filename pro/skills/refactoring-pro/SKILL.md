---
name: refactoring-pro
description: Code refactoring expertise for safe transformations, design pattern application, and complexity reduction. Use when improving code structure, reducing technical debt, or applying design patterns.
---

# Refactoring Expertise

## Safety First

Golden Rules:

1. Never refactor without tests
2. Make small, incremental changes
3. Commit after each successful refactor
4. Verify behavior is preserved

## Code Smell Detection

### Method-Level Smells

| Smell               | Symptom                                             | Refactoring                |
| ------------------- | --------------------------------------------------- | -------------------------- |
| Long Method         | >20 lines, multiple responsibilities                | Extract Method             |
| Long Parameter List | >3 parameters                                       | Introduce Parameter Object |
| Feature Envy        | Method uses another object's data more than its own | Move Method                |
| Data Clumps         | Same group of variables appear together             | Extract Class              |

### Class-Level Smells

| Smell               | Symptom                                   | Refactoring                   |
| ------------------- | ----------------------------------------- | ----------------------------- |
| Large Class         | >200 lines, multiple responsibilities     | Extract Class                 |
| Divergent Change    | Class changes for multiple reasons        | Extract Class                 |
| Shotgun Surgery     | One change requires touching many classes | Move Method, Inline Class     |
| Primitive Obsession | Using primitives instead of small objects | Replace Primitive with Object |

## Refactoring Catalog

### Extract Method

Before:

```typescript
function printInvoice(invoice: Invoice) {
  console.log("Invoice");
  console.log("--------");

  let total = 0;
  for (const item of invoice.items) {
    console.log(`${item.name}: $${item.price}`);
    total += item.price;
  }

  console.log("--------");
  console.log(`Total: $${total}`);
}
```

After:

```typescript
function printInvoice(invoice: Invoice) {
  printHeader();
  const total = printItems(invoice.items);
  printFooter(total);
}

function printHeader() {
  console.log("Invoice");
  console.log("--------");
}

function printItems(items: Item[]): number {
  let total = 0;
  for (const item of items) {
    console.log(`${item.name}: $${item.price}`);
    total += item.price;
  }
  return total;
}

function printFooter(total: number) {
  console.log("--------");
  console.log(`Total: $${total}`);
}
```

### Replace Conditional with Polymorphism

Before:

```typescript
function calculatePay(employee: Employee): number {
  switch (employee.type) {
    case "hourly":
      return employee.hours * employee.rate;
    case "salaried":
      return employee.salary / 12;
    case "commission":
      return employee.salary / 12 + employee.sales * employee.commissionRate;
  }
}
```

After:

```typescript
interface Employee {
  calculatePay(): number;
}

class HourlyEmployee implements Employee {
  constructor(
    private hours: number,
    private rate: number,
  ) {}
  calculatePay() {
    return this.hours * this.rate;
  }
}

class SalariedEmployee implements Employee {
  constructor(private salary: number) {}
  calculatePay() {
    return this.salary / 12;
  }
}

class CommissionEmployee implements Employee {
  constructor(
    private salary: number,
    private sales: number,
    private commissionRate: number,
  ) {}
  calculatePay() {
    return this.salary / 12 + this.sales * this.commissionRate;
  }
}
```

### Introduce Parameter Object

Before:

```typescript
function dateRange(startYear: number, startMonth: number, startDay: number,
                   endYear: number, endMonth: number, endDay: number) { ... }
```

After:

```typescript
interface DateRange {
    start: Date;
    end: Date;
}

function dateRange(range: DateRange) { ... }
```

## Design Pattern Application

### Strategy Pattern

When: Multiple algorithms that should be interchangeable

```typescript
interface PaymentStrategy {
  pay(amount: number): void;
}

class CreditCardPayment implements PaymentStrategy {
  pay(amount: number) {
    /* credit card logic */
  }
}

class PayPalPayment implements PaymentStrategy {
  pay(amount: number) {
    /* PayPal logic */
  }
}

class ShoppingCart {
  constructor(private paymentStrategy: PaymentStrategy) {}

  checkout(amount: number) {
    this.paymentStrategy.pay(amount);
  }
}
```

### Factory Pattern

When: Object creation logic is complex or varies

```typescript
interface Notification {
  send(message: string): void;
}

class NotificationFactory {
  create(type: "email" | "sms" | "push"): Notification {
    switch (type) {
      case "email":
        return new EmailNotification();
      case "sms":
        return new SMSNotification();
      case "push":
        return new PushNotification();
    }
  }
}
```

## Test-Driven Refactoring

### Characterization Tests

When refactoring legacy code without tests:

```typescript
// 1. Write tests that capture current behavior
test("legacy function returns expected output", () => {
  expect(legacyFunction("input")).toMatchSnapshot();
});

// 2. Run tests to create snapshot
// 3. Refactor code
// 4. Tests verify behavior unchanged
```

### Refactoring Workflow

```
1. Identify smell
2. Verify test coverage (add if missing)
3. Make smallest possible change
4. Run tests
5. Commit if green
6. Repeat
```

## Complexity Metrics

### Cyclomatic Complexity

Target: < 10 per function

```typescript
// Complexity = 4 (if, else if, for, if)
function process(items: Item[]) {
  if (items.length === 0) return; // +1

  for (const item of items) {
    // +1
    if (item.type === "A") {
      // +1
      handleA(item);
    } else if (item.type === "B") {
      // +1
      handleB(item);
    }
  }
}
```

Reduce by:

- Extract methods
- Replace conditionals with polymorphism
- Use early returns

## Legacy Code Strategies

### Seam Identification

Find points where you can alter behavior without editing code:

- Object seams (dependency injection)
- Preprocessor seams (feature flags)
- Link seams (module substitution)

### Sprout Method

Add new functionality in new method, call from legacy code:

```typescript
// Legacy code - don't modify
function processOrder(order: Order) {
  // ... existing logic ...

  // Sprout: new functionality in new method
  validateInventory(order);

  // ... existing logic ...
}

// New, tested method
function validateInventory(order: Order) {
  // new logic with full test coverage
}
```

## Quality Checklist

- [ ] Zero behavior changes verified
- [ ] Test coverage maintained continuously
- [ ] Performance improved or maintained
- [ ] Complexity reduced significantly
- [ ] Documentation updated thoroughly
- [ ] Review completed comprehensively
- [ ] Metrics tracked accurately
- [ ] Safety ensured consistently
