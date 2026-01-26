---
name: prompt-pro
description: Prompt engineering expertise for LLM interactions, agent prompting, few-shot learning, chain-of-thought reasoning, and production prompt systems. Use when designing prompts, writing skills, optimizing LLM outputs, or building agent systems.
---

# Prompt Engineering Expertise

## Core Techniques

### Few-Shot Learning

Teach by example, not explanation. Include 2-5 input-output pairs demonstrating desired behavior.

When to use:

- Consistent formatting required
- Specific reasoning patterns needed
- Edge case handling critical

Example structure:

```
[Task description]

Input: [example 1 input]
Output: [example 1 output]

Input: [example 2 input]
Output: [example 2 output]

Now process: [actual input]
```

### Chain-of-Thought

Request step-by-step reasoning before final answers. Improves accuracy 30-50% on analytical tasks.

Approaches:

- Zero-shot: Add "Let's think step by step"
- Few-shot: Include example reasoning traces

Use for:

- Complex multi-step logic
- Mathematical reasoning
- Debugging analysis
- Root cause investigation

### Prompt Optimization

Systematic improvement through testing:

1. Start simple, measure baseline
2. Add constraints incrementally
3. Test on diverse inputs including edge cases
4. A/B test variations
5. Monitor production metrics

Version control prompts like code.

### Template Systems

Build reusable prompt structures:

```python
template = """
Review this {language} code for {focus_area}.

Code:
{code_block}

Provide feedback on:
{checklist}
"""
```

Use for:

- Multi-turn conversations
- Role-based interactions
- Repeated patterns with variable inputs

### System Prompt Design

Set persistent behavior and constraints:

- Define role and expertise level
- Specify output format
- Establish safety guidelines
- Move stable instructions here to free user message tokens

## Instruction Hierarchy

```
[System Context] → [Task Instruction] → [Examples] → [Input Data] → [Output Format]
```

## Degrees of Freedom

Match specificity to task fragility:

**High freedom** (guidance only):

- Multiple valid approaches
- Context-dependent decisions
- Heuristic-based tasks

**Medium freedom** (templates/pseudocode):

- Preferred pattern exists
- Some variation acceptable
- Configuration affects behavior

**Low freedom** (exact scripts):

- Fragile, error-prone operations
- Consistency critical
- Specific sequence required

## Persuasion Principles

LLMs respond to persuasion like humans. Use ethically to ensure critical practices are followed.

**Authority**: Imperative language ("YOU MUST", "Never", "No exceptions")

- Use for discipline-enforcing skills, safety-critical practices

**Commitment**: Require announcements and explicit choices

- Use for accountability, multi-step processes

**Scarcity**: Time-bound requirements ("Before proceeding", "Immediately after")

- Use for verification requirements, preventing procrastination

**Social Proof**: Universal patterns ("Every time", "X without Y = failure")

- Use for documenting standards, warning about failures

**Unity**: Collaborative language ("our codebase", "we both want")

- Use for collaborative workflows, team culture

**Avoid**: Liking (creates sycophancy), Reciprocity (feels manipulative)

## Agent Prompting

### Context Window Management

The context window is shared public good:

- System prompt + conversation history + skills + metadata + request
- Progressive token accumulation across turns
- 200K total capacity

**Default assumption**: Claude is already smart. Only add context Claude doesn't have.

Challenge each piece:

- "Does Claude need this explanation?"
- "Can I assume Claude knows this?"
- "Does this justify its token cost?"

### Concise Is Key

Bad (~150 tokens):

```
PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need...
```

Good (~50 tokens):

```
Use pdfplumber for text extraction:
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Error Recovery

Build prompts that handle failures:

- Include fallback instructions
- Request confidence scores
- Ask for alternatives when uncertain
- Specify how to indicate missing information

## Common Pitfalls

- Over-engineering before trying simple approaches
- Example pollution (examples don't match target task)
- Context overflow from excessive examples
- Ambiguous instructions allowing multiple interpretations
- Ignoring edge cases in testing

## Token Efficiency

- Remove redundant words/phrases
- Use abbreviations after first definition
- Consolidate similar instructions
- Move stable content to system prompts

## Development Workflow

### 1. Requirements Analysis

Understand the prompt's purpose:

- Target LLM and capabilities
- Required output format
- Consistency requirements
- Token budget constraints
- Failure tolerance

### 2. Design Phase

Structure the prompt:

- Choose technique (few-shot, CoT, template)
- Set freedom level
- Apply persuasion principles if discipline-enforcing
- Design instruction hierarchy

### 3. Implementation

Write and refine:

- Start simple
- Add complexity only when needed
- Include examples if consistency matters
- Specify output format explicitly

### 4. Testing

Validate thoroughly:

- Test diverse inputs
- Include edge cases
- Measure consistency
- Check token usage
- A/B test variations

### 5. Production

Deploy and monitor:

- Version control prompts
- Track performance metrics
- Iterate based on real usage
- Document intent and reasoning

## Integration Patterns

### With RAG Systems

```
Given the following context:
{retrieved_context}

{few_shot_examples}

Question: {user_question}

Answer based solely on the context. State what's missing if insufficient.
```

### With Validation

```
{main_task}

After generating, verify:
1. Answers the question directly
2. Uses only provided context
3. Cites sources
4. Acknowledges uncertainty

Revise if verification fails.
```

## Quality Checklist

- [ ] Clear instruction hierarchy established
- [ ] Appropriate freedom level set
- [ ] Examples included when needed
- [ ] Token efficiency optimized
- [ ] Edge cases handled
- [ ] Output format specified
- [ ] Failure modes addressed
- [ ] Persuasion principles applied appropriately
