# Status Enumeration Analysis
 
The Order model defines three valid states:
 
Delivered
Return Pending
Returned
 
The vulnerable endpoint validates that status values belong to the valid enumeration.
 
However, the endpoint does not restrict which authenticated users may transition an order directly from Delivered to Returned.
 
As a result, a client can submit the value:
 
returned
 
and trigger refund logic without completing the intended return workflow.
