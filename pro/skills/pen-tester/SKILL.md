---
name: pen-tester
description: Penetration testing expertise for ethical hacking, vulnerability assessment, and security testing. Use when conducting security assessments, identifying vulnerabilities, or validating security controls.
---

# Penetration Testing Expertise

## Engagement Prerequisites

Before Testing:

- Written authorization (scope, rules of engagement)
- Emergency contacts defined
- Testing window established
- Exclusions documented
- Legal review completed

## Reconnaissance

### Passive Information Gathering

OSINT Sources:

- DNS records (dig, host, nslookup)
- WHOIS information
- Certificate transparency logs
- Social media and LinkedIn
- GitHub repositories
- Wayback Machine archives

### Active Enumeration

```bash
# DNS enumeration
dig axfr @ns1.target.com target.com
dnsrecon -d target.com -t std

# Subdomain discovery
subfinder -d target.com
amass enum -passive -d target.com

# Port scanning
nmap -sV -sC -p- target.com
masscan -p1-65535 target.com --rate=1000
```

## Web Application Testing

### OWASP Top 10 Focus

1. **Broken Access Control**
   - IDOR testing
   - Privilege escalation
   - Path traversal
   - Missing function level access control

2. **Cryptographic Failures**
   - Sensitive data in transit/rest
   - Weak algorithms
   - Key management issues

3. **Injection**
   - SQL injection
   - Command injection
   - LDAP injection
   - XPath injection

4. **Insecure Design**
   - Business logic flaws
   - Missing rate limiting
   - Insufficient anti-automation

5. **Security Misconfiguration**
   - Default credentials
   - Unnecessary features enabled
   - Missing security headers
   - Verbose error messages

### SQLi Testing

```
# Error-based
' OR '1'='1
' OR '1'='1'--
' UNION SELECT NULL--

# Boolean-based
' AND 1=1--
' AND 1=2--

# Time-based
' AND SLEEP(5)--
'; WAITFOR DELAY '0:0:5'--
```

### XSS Testing

```html
<!-- Reflected XSS -->
<script>
  alert(1);
</script>
<img src="x" onerror="alert(1)" />
<svg onload="alert(1)">
  <!-- DOM XSS -->
  javascript:alert(1) data:text/html,
  <script>
    alert(1);
  </script>
</svg>
```

## Network Penetration

### Service Exploitation

```bash
# SMB enumeration
smbclient -L //target -N
enum4linux target

# SSH brute force (authorized)
hydra -l admin -P wordlist.txt ssh://target

# Service version exploits
searchsploit [service version]
```

### Privilege Escalation

Linux:

```bash
# SUID binaries
find / -perm -4000 2>/dev/null

# Writable paths
find / -writable 2>/dev/null

# Kernel exploits
uname -a
searchsploit linux kernel [version]
```

Windows:

```powershell
# Service misconfigurations
accesschk.exe -uwcqv "Users" *

# Unquoted service paths
wmic service get name,displayname,pathname,startmode

# Always install elevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
```

## API Security Testing

Checklist:

- [ ] Authentication bypass attempts
- [ ] Authorization testing (BOLA/BFLA)
- [ ] Input validation (injection points)
- [ ] Rate limiting verification
- [ ] Token security (JWT analysis)
- [ ] Mass assignment vulnerabilities
- [ ] Information disclosure
- [ ] Business logic flaws

## Cloud Security Testing

AWS:

```bash
# S3 bucket enumeration
aws s3 ls s3://bucket-name --no-sign-request

# IAM enumeration
enumerate-iam --access-key KEY --secret-key SECRET
```

Azure:

```powershell
# Enumerate storage
az storage blob list --account-name target --container-name container
```

## Vulnerability Classification

| Severity | CVSS     | Example                       |
| -------- | -------- | ----------------------------- |
| Critical | 9.0-10.0 | RCE, Auth bypass              |
| High     | 7.0-8.9  | SQLi, Privilege escalation    |
| Medium   | 4.0-6.9  | XSS, Information disclosure   |
| Low      | 0.1-3.9  | Clickjacking, Missing headers |

## Reporting

Executive Summary:

- Business risk overview
- Key findings count by severity
- Remediation priority
- Timeline recommendations

Technical Findings Format:

```
Title: [Vulnerability Name]
Severity: [Critical/High/Medium/Low]
CVSS: [Score]
Location: [URL/IP/Component]

Description:
[What the vulnerability is]

Impact:
[Business/technical impact]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Evidence/Screenshot]

Remediation:
[Specific fix recommendations]

References:
[CVE, CWE, OWASP links]
```

## Ethical Guidelines

- Stay within authorized scope
- Document all activities
- Report critical issues immediately
- Protect discovered data
- Don't cause denial of service
- Clean up test artifacts
- Maintain confidentiality

## Quality Checklist

- [ ] Scope clearly defined and authorized
- [ ] Reconnaissance completed thoroughly
- [ ] Vulnerabilities identified systematically
- [ ] Exploits validated safely
- [ ] Impact assessed accurately
- [ ] Evidence documented properly
- [ ] Remediation provided clearly
- [ ] Report delivered comprehensively
