# Prompt Review: Tag Suggestion

## About This Prompt

Suggests relevant tags for new notes in a note-taking app. Uses user context (occupation, projects, interests) and existing tags to make personalized suggestions. Critical for the core organization UX.

---

## Current Prompt

```
Analyze this {{CONTENT_TYPE}} note. Suggest tags and classify intent.

{{CONTEXT_SECTIONS}}

## Note
{{CONTENT}}

## Instructions

### Tags (1-5)
- STRONGLY prefer existing tags when they match
- But don't force-fit: don't use "dogs" for a note about cats—create "cats" instead
- New tags: lowercase, concise (e.g., "recipes", "work")
- Include confidence (0-1) and brief reason

### Intent (pick one primary, optional secondary)
- task: action item to do
- reminder: surface at specific time/context
- idea: thought to revisit or develop
- reference: info to retrieve later
- question: something to research
- log: recording, no action needed
```

**Source:** `src/prompts/suggestions.ts:buildSuggestionPrompt`

---

## Context

| Field          | Value                                        |
| -------------- | -------------------------------------------- |
| Model          | openai/gpt-4o-mini                           |
| Call frequency | High (every note creation)                   |
| Priority       | Balanced - cost-sensitive due to high volume |

---

## Known Issues

- "STRONGLY prefer" is vague—needs clearer criteria for when to match vs create new
- Intent definitions overlap (task vs reminder, idea vs reference)
- Need examples showing how to use learned patterns effectively
- Secondary intent usage is unclear (when to include, when to omit)
- Confidence scoring guidance is missing

---

## Edge Cases

- Must not force-fit existing tags when new tag is clearly better
- Must handle notes with multiple intents (e.g., task that's also a reference)
- Must use learned patterns to avoid suggesting tags user consistently rejects
- Must respect user's custom instructions from profile
- Must handle empty/minimal context gracefully (new users)

---

## Structured Response Schema

```typescript
{
  tags: Array<{
    name: string; // Lowercase tag name
    confidence: number; // 0-1
    reason: string | null;
  }>;
  primaryIntent: {
    type: "task" | "reminder" | "idea" | "reference" | "question" | "log";
    confidence: number;
  }
  secondaryIntents: Array<{
    type: "task" | "reminder" | "idea" | "reference" | "question" | "log";
    confidence: number;
  }>;
}
```
