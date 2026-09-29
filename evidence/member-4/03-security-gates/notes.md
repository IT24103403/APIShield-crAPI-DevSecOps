# Member 4 Security Governance Notes
 
Objective:
Implement governance controls within the DevSecOps pipeline.
 
Security Gates:
- Critical findings block the pipeline.
- High findings block unless an approved exception exists.
- Medium findings generate remediation tasks.
- Low findings are informational.
 
Exception Management:
Each approved exception requires:
- Finding ID
- Scanner
- Severity
- Technical justification
- Compensating control
- Expiration date
- Approver
- Remediation owner
 
Evidence will be gathered from:
- GitHub Actions
- OWASP ZAP
- Security gate validation
- Artifact uploads
