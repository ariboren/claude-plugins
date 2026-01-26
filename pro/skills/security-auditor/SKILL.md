---
name: security-auditor
description: Security audit expertise for compliance validation, risk assessment, and security control evaluation. Use when auditing security posture, assessing compliance gaps, or evaluating security controls.
---

# Security Audit Expertise

## Compliance Frameworks

| Framework     | Focus Area            | Key Requirements                            |
| ------------- | --------------------- | ------------------------------------------- |
| SOC 2 Type II | Service organizations | Trust principles over time                  |
| ISO 27001     | ISMS                  | Risk-based security controls                |
| HIPAA         | Healthcare            | PHI protection                              |
| PCI DSS       | Payment cards         | Cardholder data security                    |
| GDPR          | Privacy               | Data subject rights                         |
| NIST CSF      | Cybersecurity         | Identify, Protect, Detect, Respond, Recover |

## Audit Methodology

### Phase 1: Planning

Scope Definition:

- Systems and applications in scope
- Compliance requirements
- Testing boundaries
- Timeline and resources
- Stakeholder expectations

Risk Assessment:

- Critical asset identification
- Threat landscape analysis
- Vulnerability prioritization
- Business impact evaluation

### Phase 2: Fieldwork

Control Testing:

- Technical controls verification
- Process/procedure review
- Policy compliance check
- Evidence collection
- Interview stakeholders

Evidence Types:

- Configuration screenshots
- Log samples
- Policy documents
- Process documentation
- Interview notes
- Test results

### Phase 3: Reporting

Finding Classification:
| Level | Impact | Action Required |
|-------|--------|-----------------|
| Critical | Business critical risk | Immediate remediation |
| High | Significant risk | Remediate within 30 days |
| Medium | Moderate risk | Remediate within 90 days |
| Low | Minor risk | Remediate within 180 days |
| Observation | Best practice | Consider for improvement |

## Access Control Audit

User Access Review:

- [ ] All accounts have valid owners
- [ ] Privileged access is justified
- [ ] Inactive accounts are disabled
- [ ] Access is reviewed periodically
- [ ] Segregation of duties enforced

Authentication Assessment:

- [ ] MFA enabled for privileged access
- [ ] Password policy enforced
- [ ] Account lockout configured
- [ ] SSO properly implemented
- [ ] Service accounts secured

## Data Security Audit

Data Classification:

- [ ] Classification scheme defined
- [ ] Data inventory maintained
- [ ] Handling procedures documented
- [ ] Labels applied consistently

Encryption Review:

- [ ] Data at rest encrypted
- [ ] Data in transit uses TLS 1.2+
- [ ] Key management documented
- [ ] Certificate lifecycle managed

## Infrastructure Audit

Server Hardening:

- [ ] CIS benchmarks applied
- [ ] Unnecessary services disabled
- [ ] Patch management current
- [ ] Logging configured
- [ ] Monitoring enabled

Network Security:

- [ ] Segmentation implemented
- [ ] Firewall rules reviewed
- [ ] IDS/IPS configured
- [ ] VPN secured properly
- [ ] DNS security enabled

## Application Security Audit

Code Review Findings:

- [ ] Input validation implemented
- [ ] Output encoding applied
- [ ] Authentication robust
- [ ] Session management secure
- [ ] Error handling appropriate

SAST/DAST Results:

- [ ] Critical vulnerabilities addressed
- [ ] False positives triaged
- [ ] Remediation tracked
- [ ] Scan coverage adequate

## Incident Response Audit

IR Plan Assessment:

- [ ] Plan documented and current
- [ ] Roles and responsibilities defined
- [ ] Communication procedures established
- [ ] Escalation paths clear
- [ ] Recovery procedures tested

Detection Capabilities:

- [ ] Alerting configured
- [ ] Correlation rules active
- [ ] Response playbooks exist
- [ ] Forensics capability ready

## Third-Party Risk

Vendor Assessment:

- [ ] Security questionnaires completed
- [ ] Certifications verified
- [ ] Data handling reviewed
- [ ] Contract terms adequate
- [ ] SLAs defined

Supply Chain:

- [ ] Dependencies inventoried
- [ ] Vulnerability monitoring active
- [ ] Update procedures defined
- [ ] Incident notification required

## Audit Report Structure

### Executive Summary

```
Overview:
- Audit scope and objectives
- Key findings summary
- Risk rating distribution
- Compliance status

Key Metrics:
- Controls tested: X
- Findings identified: Y
- Critical/High issues: Z
- Compliance score: N%
```

### Detailed Findings

```
Finding ID: SEC-001
Title: [Descriptive title]
Severity: [Critical/High/Medium/Low]
Control Area: [Access Control/Data Security/etc.]

Description:
[What was found]

Risk:
[Business and technical impact]

Evidence:
[Screenshots, logs, references]

Remediation:
[Specific steps to fix]

Timeline:
[Recommended fix date]
```

## Continuous Monitoring

Key Metrics:

- Vulnerability remediation time
- Patch compliance rate
- Policy exception count
- Access review completion
- Incident response time
- Training completion rate

## Quality Checklist

- [ ] Audit scope defined clearly
- [ ] Controls assessed thoroughly
- [ ] Vulnerabilities identified completely
- [ ] Compliance validated accurately
- [ ] Risks evaluated properly
- [ ] Evidence collected systematically
- [ ] Findings documented comprehensively
- [ ] Recommendations actionable consistently
