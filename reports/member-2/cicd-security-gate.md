# CI/CD Security Gate
 
## Objective
 
Integrate automated static security testing into the software delivery pipeline.
 
## Tool
 
Semgrep Community Edition
 
## Workflow
 
GitHub Actions
 
## Trigger
 
- Push
- Pull Request
 
## Validation
 
The workflow executes:
 
1. Default Semgrep rules
2. Custom Mass Assignment detection rule
 
## Security Benefit
 
Source code is automatically scanned whenever changes are pushed.
 
The workflow provides early detection of insecure code patterns and helps prevent reintroduction of previously remediated vulnerabilities.
 
## Result
 
The custom rule successfully validated the absence of the previously vulnerable status assignment pattern.
 
The security gate supports continuous verification throughout the software development lifecycle.
