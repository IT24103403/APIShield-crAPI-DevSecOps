# V-04 Normal Contact Mechanic Workflow
 
## Endpoint
 
`POST /workshop/api/merchant/contact_mechanic`
 
## Authentication
 
An authenticated disposable laboratory user account was used.
 
The bearer token has been redacted from all evidence.
 
## Sanitized Request
 
```json
{
  "mechanic_code": "[TEST-MECHANIC-CODE]",
  "problem_details": "Controlled Member 4 normal workflow",
  "vin": "[TEST-VIN]",
  "mechanic_api": "http://[LAB-HOST]:8888/workshop/api/mechanic/receive_report",
  "repeat_request_if_failed": false,
  "number_of_repeats": 1
}
 
