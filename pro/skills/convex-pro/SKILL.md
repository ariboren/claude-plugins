---
name: convex-pro
description: Convex platform expertise for real-time backends, serverless functions, schema design, reactive queries, HTTP actions, AI agents, and security patterns. Use when building or debugging Convex applications.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Convex Expertise

## Skill Selection

Load skills based on the task:

**Data Storage/Queries**

- Schema definition, types, indexes → `convex-schema-validator`
- Writing queries/mutations/actions → `convex-functions`
- Real-time UI patterns → `convex-realtime`

**External Integrations**

- Webhooks, REST APIs → `convex-http-actions`
- Background/scheduled jobs → `convex-cron-jobs`
- File uploads/downloads → `convex-file-storage`

**AI Features**

- Agents, tools, RAG, workflows → `convex-agents`

**Maintenance/Security**

- Schema changes → `convex-schema-field-removal-migration`
- Deep security audit → `convex-security-audit`
- Code quality review → `convex-best-practices`
- Reusable components → `convex-component-authoring`

## Function Types

| Type         | Database                 | External APIs | Use Case                         |
| ------------ | ------------------------ | ------------- | -------------------------------- |
| `query`      | Read-only                | No            | Fetching data (reactive, cached) |
| `mutation`   | Read/Write               | No            | Modifying data (transactional)   |
| `action`     | Via runQuery/runMutation | Yes           | External integrations            |
| `httpAction` | Via runQuery/runMutation | Yes           | Webhooks, REST APIs              |

## Core Principles

1. Always use validators for args and returns
2. Use indexes instead of filters for queries
3. Make mutations idempotent with early returns
4. Use internal functions for sensitive operations
5. Batch operations for large datasets

## Restrictions

- Do NOT run `npx convex deploy` without explicit instruction
- Do NOT edit files in `convex/_generated/`
- Do NOT use `filter()` instead of `withIndex()` on large tables
- Do NOT store secrets in code (use environment variables)
- Do NOT make public functions that should be internal

## Documentation

- https://docs.convex.dev/
- https://docs.convex.dev/llms.txt
