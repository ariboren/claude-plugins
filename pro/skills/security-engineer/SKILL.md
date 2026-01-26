---
name: security-engineer
description: Infrastructure security expertise for DevSecOps, cloud security, and zero-trust architecture. Use when implementing security controls, hardening infrastructure, or building security into CI/CD pipelines.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Security Engineering Expertise

## DevSecOps Practices

### Shift-Left Security

Pipeline Integration:

```yaml
# Example GitHub Actions security workflow
security:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: SAST Scan
      uses: github/codeql-action/analyze@v2

    - name: Dependency Check
      run: npm audit --audit-level=high

    - name: Container Scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE }}

    - name: IaC Scan
      uses: bridgecrewio/checkov-action@master
```

### Security Scanning

| Stage      | Tool Type         | Examples                    |
| ---------- | ----------------- | --------------------------- |
| Pre-commit | Secrets detection | gitleaks, trufflehog        |
| Build      | SAST              | CodeQL, Semgrep, SonarQube  |
| Build      | SCA               | Snyk, Dependabot, npm audit |
| Build      | Container         | Trivy, Grype, Clair         |
| Deploy     | IaC               | Checkov, tfsec, KICS        |
| Runtime    | DAST              | OWASP ZAP, Burp             |

## Cloud Security

### AWS Security

IAM Best Practices:

```hcl
# Least privilege policy
resource "aws_iam_policy" "minimal" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["arn:aws:s3:::bucket-name/*"]
      Condition = {
        StringEquals = {
          "aws:PrincipalTag/Environment": "production"
        }
      }
    }]
  })
}
```

Security Services:

- GuardDuty for threat detection
- Security Hub for posture management
- Config for compliance monitoring
- CloudTrail for audit logging
- KMS for encryption

### Container Security

Dockerfile Hardening:

```dockerfile
# Use minimal base image
FROM gcr.io/distroless/nodejs:18

# Non-root user
USER nonroot:nonroot

# Read-only filesystem
# (configured in K8s securityContext)

COPY --chown=nonroot:nonroot . /app
CMD ["server.js"]
```

Kubernetes Security:

```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
      resources:
        limits:
          memory: "128Mi"
          cpu: "500m"
```

## Zero-Trust Architecture

Principles:

1. Never trust, always verify
2. Least privilege access
3. Assume breach
4. Verify explicitly
5. Use micro-segmentation

Implementation:

- Identity-based access (not network location)
- Device health verification
- Continuous authentication
- Encrypted communications
- Micro-segmentation

## Secrets Management

### HashiCorp Vault

```bash
# Dynamic database credentials
vault write database/roles/my-role \
    db_name=postgresql \
    creation_statements="CREATE ROLE..." \
    default_ttl="1h" \
    max_ttl="24h"

# Application retrieves credentials
vault read database/creds/my-role
```

Best Practices:

- Never commit secrets to Git
- Use dynamic secrets when possible
- Rotate secrets regularly
- Audit secret access
- Use separate secrets per environment

## Vulnerability Management

### Prioritization Framework

| Factor            | Weight | Considerations            |
| ----------------- | ------ | ------------------------- |
| CVSS Score        | 40%    | Base severity             |
| Exploitability    | 25%    | Public exploit available? |
| Asset Criticality | 20%    | Business impact           |
| Exposure          | 15%    | Internet-facing?          |

### Remediation SLAs

| Severity | SLA      | Action                 |
| -------- | -------- | ---------------------- |
| Critical | 24 hours | Emergency patch        |
| High     | 7 days   | Priority remediation   |
| Medium   | 30 days  | Planned remediation    |
| Low      | 90 days  | Risk acceptance review |

## Incident Response

### Detection

```yaml
# Example SIEM alert rule
- alert: SuspiciousLogin
  condition: |
    authentication.failed_attempts > 5 AND
    time_window: 5m AND
    NOT ip_in_allowlist(source.ip)
  severity: high
  actions:
    - notify: security-team
    - block: source.ip
```

### Response Playbook

1. **Contain**: Isolate affected systems
2. **Preserve**: Collect forensic evidence
3. **Eradicate**: Remove threat
4. **Recover**: Restore services
5. **Lessons**: Post-incident review

## Security Monitoring

### Key Metrics

```
# RED for Security
- Rate: Events per second
- Errors: Failed authentications
- Duration: Detection to response time

# Coverage Metrics
- Asset inventory completeness
- Vulnerability scan coverage
- Log collection coverage
- Alert rule coverage
```

### Alerting Strategy

High-fidelity alerts:

- Successful exploitation indicators
- Data exfiltration patterns
- Privilege escalation
- Lateral movement

Low-noise approach:

- Tune out false positives
- Correlate multiple signals
- Use threat intelligence
- Context-aware alerting

## Compliance as Code

```python
# Example compliance check
def check_s3_encryption(bucket):
    """Verify S3 bucket has encryption enabled"""
    encryption = s3.get_bucket_encryption(Bucket=bucket)
    return encryption is not None

def check_public_access(bucket):
    """Verify S3 bucket blocks public access"""
    config = s3.get_public_access_block(Bucket=bucket)
    return all([
        config['BlockPublicAcls'],
        config['IgnorePublicAcls'],
        config['BlockPublicPolicy'],
        config['RestrictPublicBuckets']
    ])
```

## Quality Checklist

- [ ] CIS benchmarks compliance verified
- [ ] Zero critical vulnerabilities in production
- [ ] Security scanning in CI/CD pipeline
- [ ] Secrets management automated
- [ ] RBAC properly implemented
- [ ] Network segmentation enforced
- [ ] Incident response plan tested
- [ ] Compliance evidence automated
