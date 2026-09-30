# OWASP crAPI Risk Assessment

 
## Method

 
Risk score = Likelihood × Impact

 
## Likelihood scale

 
1 - Rare  

2 - Unlikely  

3 - Possible  

4 - Likely  

5 - Almost certain  

 
## Impact scale

 
1 - Negligible  

2 - Minor  

3 - Moderate  

4 - Major  

5 - Severe  

 
## Risk classification

 
1-4 - Low  

5-9 - Medium  

10-16 - High  

17-25 - Critical  

 
## Risk register

 
| ID | Threat | Likelihood | Impact | Score | Rating | Priority |

|---|---|---:|---:|---:|---|---:|

| T1 | Credential impersonation | 3 | 4 | 12 | High | 9 |

| T2 | Authentication token misuse | 3 | 5 | 15 | High | 5 |

| T3 | Unauthorized field modification | 4 | 4 | 16 | High | 3 |

| T4 | Unauthorized object modification | 4 | 5 | 20 | Critical | 1 |

| T5 | Insufficient security logging | 3 | 3 | 9 | Medium | 12 |

| T6 | Excessive API data exposure | 4 | 4 | 16 | High | 4 |

| T7 | CI/CD secret exposure | 3 | 5 | 15 | High | 6 |

| T8 | API resource exhaustion | 3 | 4 | 12 | High | 10 |

| T9 | Broken object-level authorization | 4 | 5 | 20 | Critical | 2 |

| T10 | Broken function-level authorization | 3 | 5 | 15 | High | 7 |

| T11 | Vulnerable dependency | 3 | 5 | 15 | High | 8 |

| T12 | CI/CD workflow manipulation | 2 | 5 | 10 | High | 11 |

 
## Risk-treatment priorities

 
### Critical

 
- T4 Unauthorized object modification

- T9 Broken object-level authorization

 
### High

 
- T3 Unauthorized field modification

- T6 Excessive API data exposure

- T2 Token misuse

- T7 Secret exposure

- T10 Function-level authorization failure

- T11 Vulnerable dependency

- T1 Credential impersonation

- T8 Resource exhaustion

- T12 Workflow manipulation

 
### Medium

 
- T5 Insufficient security logging

 
## Risk-treatment strategy

 
- Avoid: Do not expose the intentionally vulnerable environment publicly.

- Mitigate: Introduce validation, authorization, SAST and CI/CD controls.

- Transfer: Not applicable within the educational laboratory.

- Accept: Only documented residual risks required by the intentionally vulnerable training environment.
 
