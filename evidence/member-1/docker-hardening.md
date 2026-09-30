# Docker Hardening Evidence

## Control 1: Non-root container execution

The explicit `user: root` setting was removed from the MailHog service in the Docker Compose configuration.

The MailHog image was verified to use its default non-root user.

Verification:

`docker exec mailhog id`

Result:

`uid=1000(mailhog) gid=1000(mailhog) groups=1000(mailhog)`

## Control 2: Container resource limits

The Docker Compose configuration defines CPU and memory limits for the deployed services. These limits reduce the risk of a single container consuming excessive host resources.

## Existing security settings

The MailHog container was verified with:

- Privileged mode: disabled
- Read-only root filesystem: not enabled
- Additional Linux capabilities dropped: none

No unnecessary changes were made to these settings because the application was already functioning correctly and the assignment requires testing controls after modification.

## Validation

After the non-root hardening change, the crAPI web application remained accessible and returned HTTP 200.
