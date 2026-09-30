# APIShield Security Exception Register
 
## Security Gate Policy
 
### Critical
- Pipeline blocked
- Immediate remediation required
- Exception approval mandatory
 
### High
- Pipeline blocked unless approved security exception exists
- Remediation target required
 
### Medium
- Pipeline continues with warning
- Remediation task created
 
### Low
- Informational finding
- Tracked for future improvement
 
---
 
## Security Exception Template
 
### Finding ID
SEC-001
 
### Scanner
OWASP ZAP / Semgrep / Trivy / Gitleaks
 
### Severity
Critical / High / Medium / Low
 
### Technical Justification
Explain why the finding cannot currently be remediated.
 
### Compensating Control
Describe alternative security controls that reduce risk.
 
### Expiration Date
YYYY-MM-DD
 
### Approver
Security Lead
 
### Remediation Owner
Project Team Member
 
### Status
Open / Approved / Expired / Remediated
 
---
 
## Example Exception
 
### Finding ID
SEC-001
 
### Scanner
OWASP ZAP
 
### Severity
Medium
 
### Technical Justification
Missing Content-Security-Policy header identified during baseline DAST assessment.
Application is deployed only within the isolated educational laboratory environment.
 
### Compensating Control
No internet-facing deployment.
Access restricted to local Docker environment.
 
### Expiration Date
2026-12-31
 
### Approver
Project Supervisor
 
### Remediation Owner
Member 4
 
### Status
Approved
 
 
