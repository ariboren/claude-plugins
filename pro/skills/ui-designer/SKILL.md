---
name: ui-designer
description: UI design expertise for visual design, interaction patterns, and design systems. Use when designing interfaces, implementing design systems, or improving user experience.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# UI Design Expertise

## Visual Hierarchy

### Typography Scale

```css
/* Modular scale (1.25 ratio) */
--text-xs: 0.64rem; /* 10.24px */
--text-sm: 0.8rem; /* 12.8px */
--text-base: 1rem; /* 16px */
--text-lg: 1.25rem; /* 20px */
--text-xl: 1.563rem; /* 25px */
--text-2xl: 1.953rem; /* 31.25px */
--text-3xl: 2.441rem; /* 39px */
```

### Spacing System

```css
/* 4px base unit */
--space-1: 0.25rem; /* 4px */
--space-2: 0.5rem; /* 8px */
--space-3: 0.75rem; /* 12px */
--space-4: 1rem; /* 16px */
--space-6: 1.5rem; /* 24px */
--space-8: 2rem; /* 32px */
--space-12: 3rem; /* 48px */
--space-16: 4rem; /* 64px */
```

### Color System

```css
/* Semantic colors */
--color-primary: #3b82f6;
--color-secondary: #6b7280;
--color-success: #10b981;
--color-warning: #f59e0b;
--color-error: #ef4444;

/* Neutral scale */
--gray-50: #f9fafb;
--gray-100: #f3f4f6;
--gray-200: #e5e7eb;
--gray-500: #6b7280;
--gray-900: #111827;
```

## Component Patterns

### Button States

```
Default → Hover → Active → Focus → Disabled

Visual feedback:
- Hover: Slight background change
- Active: Pressed appearance (darker)
- Focus: Visible ring (accessibility)
- Disabled: Reduced opacity, no pointer events
```

### Form Elements

Input States:

- Default: Subtle border
- Focus: Highlighted border, shadow
- Error: Red border, error message
- Disabled: Gray background, muted text
- Success: Green indicator

Best Practices:

- Labels above inputs (not placeholders)
- Visible focus states
- Inline validation feedback
- Clear error messages
- Required field indicators

### Cards

Structure:

```
┌─────────────────────────┐
│ [Image/Media]           │
├─────────────────────────┤
│ Eyebrow text            │
│ Heading                 │
│ Body text that wraps    │
│ across multiple lines   │
├─────────────────────────┤
│ [Actions]               │
└─────────────────────────┘
```

## Responsive Design

### Breakpoints

```css
/* Mobile-first breakpoints */
--breakpoint-sm: 640px; /* Large phones */
--breakpoint-md: 768px; /* Tablets */
--breakpoint-lg: 1024px; /* Laptops */
--breakpoint-xl: 1280px; /* Desktops */
--breakpoint-2xl: 1536px; /* Large screens */
```

### Layout Patterns

Mobile: Single column, stacked
Tablet: 2 columns, side navigation
Desktop: Multi-column, full navigation

Fluid Typography:

```css
/* Scales between 16px (mobile) and 20px (desktop) */
font-size: clamp(1rem, 0.5rem + 1vw, 1.25rem);
```

## Motion Design

### Timing Functions

```css
/* Standard easing */
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);

/* Durations */
--duration-fast: 150ms;
--duration-normal: 300ms;
--duration-slow: 500ms;
```

### Animation Principles

- Micro-interactions: 100-300ms
- Page transitions: 300-500ms
- Respect prefers-reduced-motion
- Entrance > exit (exits can be faster)
- Consistent direction and easing

## Dark Mode

### Color Adaptation

```css
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f3f4f6;
  --text-primary: #111827;
  --text-secondary: #6b7280;
}

[data-theme="dark"] {
  --bg-primary: #111827;
  --bg-secondary: #1f2937;
  --text-primary: #f9fafb;
  --text-secondary: #9ca3af;
}
```

Considerations:

- Reduce contrast slightly (not pure white on black)
- Elevate surfaces with lighter backgrounds
- Adjust shadows (lighter, more diffuse)
- Test images and illustrations

## Accessibility

### Focus Indicators

```css
/* Visible focus ring */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Remove default for mouse users */
:focus:not(:focus-visible) {
  outline: none;
}
```

### Color Contrast

- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum
- Don't rely on color alone

### Touch Targets

- Minimum 44x44px
- Adequate spacing between targets
- Visual feedback on touch

## Design Tokens

```json
{
  "color": {
    "primary": {
      "50": { "value": "#EFF6FF" },
      "500": { "value": "#3B82F6" },
      "900": { "value": "#1E3A8A" }
    }
  },
  "spacing": {
    "xs": { "value": "4px" },
    "sm": { "value": "8px" },
    "md": { "value": "16px" }
  },
  "borderRadius": {
    "sm": { "value": "4px" },
    "md": { "value": "8px" },
    "full": { "value": "9999px" }
  }
}
```

## Quality Checklist

- [ ] Visual hierarchy clear
- [ ] Typography scale consistent
- [ ] Spacing system applied
- [ ] Color contrast passing
- [ ] Interactive states defined
- [ ] Focus indicators visible
- [ ] Motion is purposeful
- [ ] Dark mode tested
- [ ] Responsive layouts working
- [ ] Touch targets adequate
