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


## Enforcement

The Semgrep workflow was configured to run during:

- Push events
- Pull-request events

The SAST stage executed:

1. The general Semgrep ruleset
2. The project-specific Mass Assignment rule

The custom rule identifier was:

text
crapi-client-controlled-order-status


The rule detected the prohibited source pattern:

python
order.status = request_data["status"]


The targeted comparison produced:

text
Before remediation: 1 finding
After remediation: 0 findings


## Controlled Security-Gate Validation

A temporary educational regression was used to verify that the security gate could block unsafe code.

The validation sequence was:

text
Unsafe direct status-assignment pattern introduced
        ↓
Custom Semgrep rule detected the pattern
        ↓
GitHub Actions security job failed
        ↓
Unsafe pattern removed
        ↓
Custom Semgrep rule returned no finding
        ↓
GitHub Actions security job passed


This demonstrated that the pipeline enforced the security rule rather than only displaying informational scan output.

## Member Ownership and Pipeline Integration

Member 2 was responsible for:

- Semgrep baseline scanning
- Manual finding triage
- Custom Mass Assignment rule development
- Targeted before-and-after SAST verification
- Reusable Semgrep workflow configuration

Member 4 was responsible for integrating the Member 2 SAST stage into the consolidated DevSecOps pipeline together with:

- Dependency and filesystem scanning
- Secret scanning
- Container-image scanning
- Dynamic application security testing
- Security-gate governance
- Evidence-artifact publication

## Architecture Mapping

The CI/CD security control applies across:

text
TB5: CI/CD → Environment


The security gate helps prevent the vulnerable order-status assignment from being reintroduced and deployed into the application environment.

The runtime vulnerability itself affected:

text
DF6: Web → Workshop Service
DF11: Workshop Service → MongoDB Workshop Data
TB2: Web → Backend Services
TB3: Services → Databases


## Evidence

- M2_44_Custom_Mass_Assignment_Rule.png
- M2_45_Custom_Rule_Validation.png
- M2_46_Custom_Rule_Before_Fix.png
- M2_47_Custom_Rule_After_Fix.png
- M2_50_SAST_Before_After_Comparison.png
- M2_51_GitHub_Workflow_YAML.png
- M2_52_GitHub_Action_Started.png
- M2_53_GitHub_Actions_Run.png
- M2_54_GitHub_Action_Log.png
- M2_55_Controlled_SAST_Failure.png
- M2_56_SAST_Gate_Passed.png

## Final Result

The CI/CD security gate provided continuous verification against reintroduction of the remediated source pattern.

Final targeted result:

text
Vulnerable source: 1 finding
Remediated source: 0 findings
Controlled regression: Workflow failed
Corrected source: Workflow passed


The gate therefore provided automated recurrence protection for the confirmed Member 2 Mass Assignment vulnerability.
