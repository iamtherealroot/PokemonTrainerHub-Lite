# Public deployment security / Absicherung für den Onlinebetrieb

This repository provides a RomM-based deployment, **not** a security-audited managed hosting service. Do not expose it publicly before completing the checklist.

## Recommended topology

Internet -> HTTPS 443 -> reverse proxy (Nginx Proxy Manager or Caddy) -> RomM 8080 -> internal MariaDB. Never publish MariaDB 3306 or internal Valkey 6379. If reverse proxy is on the **same host**, bind RomM on `127.0.0.1`. If proxy is on **another host**, bind RomM only to the dedicated private network address and restrict ingress to the proxy's IP using the network firewall. Do not set a public wildcard bind without such restrictions.

Docker published ports may bypass ordinary UFW INPUT filtering. Use Docker-aware filtering, a hypervisor/firewall rule, or a narrowly bound interface. Check both IPv4 and IPv6.

## Existing installations (IMPORTANT)

Your existing `/opt/pokemonhub/romm/docker-compose.yml` currently publishes `8080:8080` on all host interfaces, including IPv6. The lite override only adds CPU/RAM caps. **Do not claim it secures the public port.**

Before making changes, verify where your proxy lives and how it reaches RomM. If proxy lives locally, change the `romm` port mapping to `127.0.0.1:8080:8080`. If proxy lives elsewhere, bind to a private interface and firewall off access except from the reverse proxy. This may interrupt LAN access until NPM is configured. Test before deleting the original route.

`sudo bash scripts/security-audit.sh` runs read-only checks and prints warnings. It never changes firewall rules or credentials.

## New installations

The fresh installer binds to `127.0.0.1:8080` by default. This is appropriate for a local reverse proxy. `--bind 0.0.0.0` exposes the HTTP service on network interfaces and is **not recommended for internet-facing servers**.

Install a reverse proxy such as NPM (existing infrastructure) or Caddy. Configure the public domain and automatic certificate renewal. Forward requests to the private RomM endpoint. Preserve upgrade and websocket headers. Avoid proxy authentication schemes that break the RomM client API until tested.

## Identity / session policy

- Invite-only: disable public self-registration in RomM settings; test that anonymous registration is impossible.
- Keep kiosk/anonymous mode disabled.
- Create a separate administrator account; give ordinary users non-admin rights.
- For public access, prefer an OIDC provider with MFA (e.g., Authentik); verify an admin OIDC login works before disabling local passwords.
- Never enable `DISABLE_CSRF_PROTECTION`.
- Set `SESSION_MAX_AGE_SECONDS=43200` for a 12-hour maximum session lifespan. Confirm user experience with local and companion apps.
- Rotate API tokens following a suspected leak; preserve `ROMM_AUTH_SECRET_KEY` in secure backups (changing it invalidates sessions).

## Reverse proxy example (Caddy, same host)

```caddyfile
pokemon.example.net {
    encode zstd gzip
    header {
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
        X-Frame-Options SAMEORIGIN
        X-Robots-Tag "noindex, nofollow"
        -Server
    }
    reverse_proxy 127.0.0.1:8080
}
```

For an NPM instance on a separate server, point its upstream to the private LAN IP, not loopback. The access control should be enforced at the network firewall.

## Host hardening

- Debian/Ubuntu security updates and scheduled maintenance; pin Docker/RomM image versions for reproducible upgrades.
- SSH key login, disable password login after verifying key access; never disable access prematurely.
- Limit SSH to management VPN and trusted IPs; no SSH forwarding from public router.
- Set fail2ban or another rate-limiter for SSH and proxy-facing authentication, based on **verified** real client IP configuration.
- Keep backups off host: database-consistent backups + assets/saves/config, encryption, retention, test restore. A Hyper-V checkpoint is not a complete backup.
- Monitor disk space, container restarts, failed logins, HTTP 5xx rates, certificate expiration, and image vulnerabilities.
- Do not commit `.env`, ROMs, firmware, saves, exports, tokens or dumps to Git.

## Safe public launch checklist

- [ ] Domain points to intended reverse proxy; valid TLS and renewals work
- [ ] No direct Internet route to port 8080, 3306 or 6379 (IPv4 and IPv6)
- [ ] No unauthenticated registration, kiosk mode, or unauthorized ROM access
- [ ] MFA-enabled OIDC or documented equivalent authentication risk
- [ ] User A cannot read User B saves; admin permissions verified
- [ ] Backups made and restored in a test environment
- [ ] Docker images and OS updated/pinned with rollback plan
- [ ] Reverse proxy rate limits and logging tested
- [ ] External verification from outside LAN completed
- [ ] No ROM content offered without legal permission

## References

- RomM authentication: https://docs.romm.app/latest/Getting-Started/Authentication/
- RomM reverse proxy: https://docs.romm.app/5.4.0/install/reverse-proxy/
- Docker packet filtering: https://docs.docker.com/engine/network/packet-filtering-firewalls/
