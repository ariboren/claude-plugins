---
name: backend-dev
description: Backend development expertise for scalable APIs, microservices architecture, database design, and server-side performance. Use when building APIs, implementing authentication, designing database schemas, or optimizing server performance.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Backend Development Expertise

## API Design Requirements

Endpoint Design:

- Consistent naming conventions (kebab-case)
- Proper HTTP status code usage
- Request/response validation
- API versioning strategy
- Rate limiting implementation
- CORS configuration
- Pagination for list endpoints
- Standardized error responses

## Database Architecture

Schema Design:

- Normalized schema for relational data
- Denormalization only for proven performance needs
- Appropriate data types (don't use VARCHAR for everything)
- Foreign key constraints for referential integrity
- Check constraints for data validation

Indexing Strategy:

- Index columns used in WHERE, JOIN, ORDER BY
- Composite indexes for multi-column queries
- Partial indexes for filtered queries
- Avoid over-indexing (hurts write performance)

Connection Management:

- Connection pooling (pgBouncer, HikariCP)
- Appropriate pool size (connections = cores \* 2 + disk spindles)
- Connection timeout configuration
- Health checks for stale connections

Transactions:

- Keep transactions short
- Use appropriate isolation levels
- Handle deadlocks with retry logic
- Savepoints for partial rollbacks

## Security Implementation

Input Validation:

- Validate all user input server-side
- Use parameterized queries (never string concatenation)
- Sanitize for context (HTML, SQL, shell)
- Validate content types and sizes

Authentication:

- Hash passwords with bcrypt/argon2 (never MD5/SHA1)
- Use secure session management
- Implement MFA where appropriate
- Token expiration and rotation

Authorization:

- Role-based access control (RBAC)
- Attribute-based for complex rules
- Check authorization at every endpoint
- Principle of least privilege

Data Protection:

- Encrypt sensitive data at rest
- TLS for all connections
- Mask sensitive data in logs
- PII handling compliance (GDPR, CCPA)

## Performance Optimization

Response Time Targets:

- p95 latency < 100ms for simple queries
- p95 latency < 500ms for complex operations

Caching Layers:

- Application cache (Redis, Memcached)
- Query result caching
- HTTP caching headers
- CDN for static assets

Async Processing:

- Message queues for background tasks
- Event-driven architecture for decoupling
- Batch processing for bulk operations
- Job scheduling for periodic tasks

Database Optimization:

- Query analysis with EXPLAIN
- N+1 query prevention
- Efficient pagination (cursor-based)
- Read replicas for scaling reads

## Microservices Patterns

Service Design:

- Single responsibility per service
- API-first design
- Independent deployment
- Service mesh for communication

Communication:

- Synchronous: REST, gRPC
- Asynchronous: Message queues, events
- Circuit breakers for resilience
- Timeouts and retries with backoff

Data Management:

- Database per service
- Saga pattern for distributed transactions
- Event sourcing for audit trails
- CQRS for read/write separation

## Message Queue Integration

Patterns:

- Work queues for task distribution
- Pub/sub for event broadcasting
- Request/reply for RPC over queues
- Priority queues for urgent tasks

Reliability:

- Acknowledgments and dead letter queues
- Idempotent message processing
- Message deduplication
- Ordered processing when needed

## Monitoring and Observability

Logging:

- Structured logging (JSON format)
- Correlation IDs across services
- Log levels (DEBUG, INFO, WARN, ERROR)
- Centralized log aggregation

Metrics:

- RED method: Rate, Errors, Duration
- USE method: Utilization, Saturation, Errors
- Custom business metrics
- Prometheus/Grafana stack

Tracing:

- Distributed tracing (OpenTelemetry)
- Span context propagation
- Trace sampling strategies
- Service dependency mapping

Health Checks:

- Liveness probes (is the process running?)
- Readiness probes (can it handle traffic?)
- Dependency health checks
- Graceful degradation

## Testing Methodology

Unit Tests:

- Test business logic in isolation
- Mock external dependencies
- Test edge cases and error paths
- Aim for 80%+ coverage

Integration Tests:

- Test API endpoints end-to-end
- Use test database with migrations
- Test authentication flows
- Verify error responses

Performance Tests:

- Load testing with realistic patterns
- Stress testing for limits
- Soak testing for memory leaks
- Benchmark critical paths

## Container Configuration

Dockerfile Best Practices:

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

Configuration:

- Environment variables for config
- Secrets management (not in images)
- Health check endpoints
- Graceful shutdown handling
- Resource limits

## Quality Checklist

- [ ] RESTful API design with proper HTTP semantics
- [ ] Database schema optimization and indexing
- [ ] Authentication and authorization implementation
- [ ] Caching strategy for performance
- [ ] Error handling and structured logging
- [ ] API documentation with OpenAPI spec
- [ ] Security measures following OWASP guidelines
- [ ] Test coverage exceeding 80%
