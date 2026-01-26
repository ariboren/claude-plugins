---
name: a11y-pro
description: Accessibility testing expertise for WCAG compliance, screen reader compatibility, keyboard navigation, and assistive technology integration. Use when auditing accessibility, implementing ARIA, or ensuring inclusive design.
allowed-tools: Read, Grep, Glob, Bash
---

# Accessibility Expertise

## WCAG Compliance Testing

Perceivable:

- Text alternatives for non-text content
- Captions and audio descriptions
- Content adaptable to different presentations
- Distinguishable content (color, contrast)

Operable:

- Keyboard accessible
- Enough time to read/use content
- No seizure-inducing content
- Navigable structure

Understandable:

- Readable text content
- Predictable functionality
- Input assistance for errors

Robust:

- Compatible with assistive technologies
- Valid, parseable markup

## Screen Reader Compatibility

### Testing Procedures

NVDA (Windows):

- Download from nvaccess.org
- Use browse mode (default) and focus mode (NVDA+Space)
- Test reading order, landmarks, headings

JAWS (Windows):

- Commercial screen reader
- Test virtual cursor navigation
- Verify forms mode behavior

VoiceOver (macOS/iOS):

- Cmd+F5 to enable on Mac
- Triple-click home/side button on iOS
- Test rotor navigation

Narrator (Windows):

- Win+Ctrl+Enter to enable
- Test scan mode navigation

### Key Testing Points

- Content announcement order matches visual order
- All interactive elements have accessible names
- Live regions announce dynamic content
- Tables have proper headers and relationships
- Form fields have associated labels

## Keyboard Navigation

Tab Order:

- Logical, predictable sequence
- No keyboard traps
- Skip links to main content
- Focus visible at all times

Focus Management:

- Focus moves to modals when opened
- Focus returns when modals close
- Focus doesn't get lost after dynamic updates

Keyboard Shortcuts:

- Document all shortcuts
- Allow remapping if possible
- Don't override browser/OS shortcuts

## ARIA Implementation

### Priority Order

1. Use semantic HTML first (button, nav, main, etc.)
2. Add ARIA only when HTML semantics insufficient
3. Never use ARIA that contradicts HTML semantics

### Common Patterns

Landmarks:

```html
<nav aria-label="Main navigation">
  <main>
    <aside aria-label="Related content">
      <footer></footer>
    </aside>
  </main>
</nav>
```

Live Regions:

```html
<div aria-live="polite" aria-atomic="true">Status messages appear here</div>
```

Dialogs:

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Dialog Title</h2>
</div>
```

### States and Properties

- aria-expanded for collapsible content
- aria-selected for tabs/options
- aria-checked for checkboxes
- aria-pressed for toggle buttons
- aria-disabled vs disabled attribute
- aria-hidden to hide from assistive tech

## Visual Accessibility

### Color Contrast

- Normal text: 4.5:1 minimum (AA), 7:1 enhanced (AAA)
- Large text (18pt+): 3:1 minimum (AA), 4.5:1 enhanced (AAA)
- UI components: 3:1 against adjacent colors
- Use tools: WebAIM Contrast Checker, axe DevTools

### Don't Rely on Color Alone

- Add icons, patterns, or text labels
- Underline links (not just color difference)
- Error states need more than red color

### Animation and Motion

- Respect prefers-reduced-motion
- Provide pause/stop controls
- Avoid flashing content (3 flashes/second max)

## Form Accessibility

Labels:

```html
<label for="email">Email address</label>
<input type="email" id="email" name="email" />
```

Error Messages:

```html
<input type="email" aria-describedby="email-error" aria-invalid="true" />
<span id="email-error" role="alert">Please enter a valid email</span>
```

Required Fields:

```html
<input type="text" required aria-required="true" />
<span aria-hidden="true">*</span>
```

Field Groups:

```html
<fieldset>
  <legend>Shipping Address</legend>
  <!-- related fields -->
</fieldset>
```

## Testing Methodology

### Automated Testing

Tools:

- axe DevTools (browser extension)
- WAVE (browser extension)
- Lighthouse accessibility audit
- eslint-plugin-jsx-a11y

Limitations:

- Catches ~30% of issues
- Can't test reading order, focus management
- False positives/negatives possible

### Manual Testing

1. Keyboard-only navigation
2. Screen reader testing
3. Zoom to 200%
4. High contrast mode
5. Reduced motion settings

### User Testing

- Include users with disabilities
- Test with actual assistive technologies
- Gather qualitative feedback

## Mobile Accessibility

Touch Targets:

- Minimum 44x44 CSS pixels
- Adequate spacing between targets

Gestures:

- Provide alternatives to complex gestures
- Support assistive technology gestures

Screen Reader Gestures:

- iOS: swipe left/right to navigate
- Android: swipe then double-tap to activate

## Quality Checklist

- [ ] WCAG 2.1 Level AA compliance
- [ ] Zero critical violations
- [ ] Keyboard navigation complete
- [ ] Screen reader compatibility verified
- [ ] Color contrast ratios passing
- [ ] Focus indicators visible
- [ ] Error messages accessible
- [ ] Alternative text comprehensive
