# Semgrep Before-and-After Comparison
 
## Baseline Scan
 
Tool:
Semgrep Community Edition
 
Ruleset:
p/default
 
Target:
crAPI Source Code
 
Purpose:
Identify potential security weaknesses and insecure coding patterns.
 
## Security Assessment
 
Selected Vulnerability:
Mass Assignment
 
Endpoint:
POST /workshop/api/shop/orders
 
Test Result:
The injected field `credit` was ignored by backend processing.
 
Root Cause Investigation:
The endpoint validates request data using ProductQuantitySerializer and only processes:
 
- product_id
- quantity
 
The tested field was not referenced in the source code.
 
## Remediation Decision
 
No code change was required because the tested parameter was already protected through existing implementation controls.
 
## Security Verification
 
A modified request containing:
 
credit = 9999
 
was submitted.
 
Result:
 
- Request succeeded.
- Order was created.
- Backend-generated credit value was returned.
- No proof of mass assignment was observed.
 
## Final Conclusion
 
The tested endpoint demonstrated existing protection against the assessed parameter and no exploitable mass-assignment condition was confirmed.


##############################################################################################################################

# SAST Before-and-After Comparison
 
## Tool Information
 
- Tool: Semgrep Community Edition
- General ruleset: p/default
- Project-specific rule: crapi-client-controlled-order-status
- Scan scope: OWASP crAPI source code
- Affected file: services/workshop/crapi/shop/views.py
 
## Vulnerable Source Result
 
The custom Semgrep rule detected the following unsafe pattern in the
original source:
 
order.status = request_data["status"]
 
This pattern allowed a client-controlled request property to determine
the final order state.
 
Custom-rule findings before remediation:
 
1
 
## Remediated Source Result
 
The same custom rule was executed against the remediated source file.
 
Custom-rule findings after remediation:
 
0
 
The direct assignment from request data to order status was no longer
present.
 
## General Scan Comparison
 
Baseline total findings:
 
Add actual baseline count.
 
Post-remediation total findings:
 
Add actual post-remediation count.
 
The general finding count may remain similar because crAPI intentionally
contains multiple unrelated vulnerable behaviours. Therefore, the
effectiveness of this remediation was evaluated using the targeted
custom rule, source-code review and runtime retesting.
 
## Runtime Correlation
 
Before remediation:
 
- Order status changed from delivered to returned.
- Balance increased from 40 to 50.
 
After remediation:
 
- The identical request was rejected.
- Order status remained unchanged.
- Account balance remained unchanged.
 
## Conclusion
 
The targeted Semgrep rule detected the vulnerable source pattern before
remediation and returned no finding against the corrected source.
Runtime testing also confirmed that direct status manipulation no
longer produced an unauthorized refund.
 
 
