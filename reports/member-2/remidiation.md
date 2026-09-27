# Remediation
 
## Objective
 
Prevent authenticated users from directly modifying order status values through the order update API.
 
## File Modified
 
crAPI/services/workshop/crapi/shop/views.py
 
## Original Behaviour
 
The endpoint accepted a client-controlled status value and allowed direct transitions to:
 
returned
 
which immediately triggered account refund logic.
 
## Security Fix
 
Direct status updates were removed from the PUT endpoint.
 
The endpoint now rejects any user-supplied status change request with HTTP 403 Forbidden.
 
Legitimate status changes must occur through the dedicated business workflow:
 
POST /workshop/api/shop/orders/return_order
 
## Expected Outcome
 
Users can no longer bypass the intended return process by submitting arbitrary status values.

## Version Control Evidence
 
The security remediation was committed to source control using Git.
 
Commit Message:
 
security: prevent direct order status manipulation
 
This provides traceability between the identified vulnerability and the implemented fix
 

## Runtime Deployment Verfication

Runtime deployment verification was successfully completed.
 
The vulnerable source code was remediated and incorporated into a custom Docker image (crapi-workship-fixed:latest). The original deployment architecture relied on a prebuilt image (crapi/crapi-workshop:latest), preventing source code changes from being reflected automatically.
 
After deploying the custom image and recreating the workshop container, the previously successful order-status manipulation attack was re-executed. The application no longer permitted direct status modification and no unauthorized refund was issued. This verified that the remediation was effective in both source code and runtime environments.
