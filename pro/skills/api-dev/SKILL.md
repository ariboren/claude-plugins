---
name: api-dev
description: API architecture expertise for REST and GraphQL design, OpenAPI specifications, versioning strategies, and developer experience. Use when designing APIs, writing documentation, or implementing authentication patterns.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# API Design Expertise

## REST Design Principles

Resource-Oriented Architecture:

- URLs identify resources, not actions
- Use nouns, not verbs: `/users` not `/getUsers`
- Hierarchical relationships: `/users/{id}/orders`

HTTP Methods:

- GET: Read (idempotent, cacheable)
- POST: Create (not idempotent)
- PUT: Full update (idempotent)
- PATCH: Partial update
- DELETE: Remove (idempotent)

Status Codes:

- 200 OK: Successful GET/PUT/PATCH
- 201 Created: Successful POST
- 204 No Content: Successful DELETE
- 400 Bad Request: Client error, validation failure
- 401 Unauthorized: Missing/invalid authentication
- 403 Forbidden: Authenticated but not authorized
- 404 Not Found: Resource doesn't exist
- 409 Conflict: Resource state conflict
- 422 Unprocessable Entity: Semantic validation error
- 429 Too Many Requests: Rate limited
- 500 Internal Server Error: Server failure

## GraphQL Schema Design

Type System:

```graphql
type User {
  id: ID!
  email: String!
  profile: Profile
  orders(first: Int, after: String): OrderConnection!
}

type Query {
  user(id: ID!): User
  users(filter: UserFilter): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}
```

Best Practices:

- Use connections for pagination (Relay spec)
- Input types for mutations
- Payload types with errors
- Avoid deeply nested queries
- Implement query complexity limits

## API Versioning

URI Versioning:

```
/v1/users
/v2/users
```

Header Versioning:

```
Accept: application/vnd.api+json; version=1
```

Deprecation Policy:

- Announce deprecation 6+ months ahead
- Provide migration guides
- Support old versions during transition
- Use Sunset header for deprecation dates

## Authentication Patterns

OAuth 2.0 Flows:

- Authorization Code: Web apps with backend
- PKCE: Mobile/SPA apps
- Client Credentials: Server-to-server
- Device Code: Limited input devices

JWT Best Practices:

- Short expiration (15 min access tokens)
- Refresh token rotation
- Include minimal claims
- Sign with RS256 for distributed systems
- Validate issuer, audience, expiration

API Keys:

- Use for service identification, not user auth
- Hash stored keys (like passwords)
- Support key rotation
- Rate limit per key

## Pagination Patterns

Cursor-Based (Recommended):

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTIzfQ==",
    "has_more": true
  }
}
```

Offset-Based:

```json
{
  "data": [...],
  "pagination": {
    "total": 1000,
    "page": 2,
    "per_page": 20
  }
}
```

Cursor advantages:

- Stable with concurrent writes
- Better performance on large datasets
- No "skipped items" problem

## Error Handling

Consistent Error Format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address"
      }
    ],
    "request_id": "req_abc123"
  }
}
```

Error Codes:

- Use machine-readable codes
- Provide human-readable messages
- Include request IDs for debugging
- Document all error codes

## Rate Limiting

Headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
Retry-After: 60
```

Strategies:

- Token bucket for bursty traffic
- Fixed window for simplicity
- Sliding window for accuracy
- Different limits per endpoint/user tier

## Documentation Standards

OpenAPI 3.1:

```yaml
openapi: 3.1.0
info:
  title: User API
  version: 1.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: Success
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserList"
```

Documentation Must Include:

- Authentication instructions
- Request/response examples
- Error code catalog
- Rate limit information
- Changelog

## Webhook Design

Event Payload:

```json
{
  "id": "evt_123",
  "type": "user.created",
  "created_at": "2024-01-15T10:30:00Z",
  "data": {
    "user": { ... }
  }
}
```

Best Practices:

- Sign payloads (HMAC-SHA256)
- Include event ID for idempotency
- Retry with exponential backoff
- Provide webhook testing tools
- Log delivery attempts

## Performance Optimization

Response Time Targets:

- p50: < 100ms
- p95: < 500ms
- p99: < 1000ms

Techniques:

- Compression (gzip, brotli)
- Connection keep-alive
- HTTP/2 multiplexing
- Caching with ETags
- Partial responses (sparse fieldsets)
- Batch endpoints for multiple operations

## Quality Checklist

- [ ] RESTful principles properly applied
- [ ] OpenAPI 3.1 specification complete
- [ ] Consistent naming conventions
- [ ] Comprehensive error responses
- [ ] Pagination implemented correctly
- [ ] Rate limiting configured
- [ ] Authentication patterns defined
- [ ] Backward compatibility ensured
