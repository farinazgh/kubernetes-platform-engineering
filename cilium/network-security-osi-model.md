# Kubernetes Network Security and the OSI Model

A practical reference for understanding how Cilium, Istio, encryption, and application-level authentication relate to the OSI model.

## 1. Security controls by OSI layer

| Technology | OSI association | Purpose |
|---|---|---|
| Cilium identity policy | L3 | Who can communicate? |
| Cilium port policy | L4 | Which port and transport protocol are permitted? |
| Session management | L5, conceptually | Is the session valid? |
| Istio mTLS | L6, conceptually | Is communication mutually authenticated and encrypted? |
| Cilium HTTP policy | L7 | Which API operations are permitted? |

## 2. Authentication and session management

| Technology | OSI association |
|---|---|
| Establishing and maintaining communication sessions | L5, conceptually |
| TLS / Istio mTLS | L6, conceptually |
| HTTP Bearer token | L7 |
| JWT access token | L7 |
| OAuth 2.0 / OpenID Connect (OIDC) | L7 |
| AWS IAM Identity Center (formerly AWS SSO) authentication | L7 |
| AWS STS temporary security credentials | L7, when issued and used for AWS API authentication |

## 3. Encryption in transit

| Technology | OSI association | Purpose |
|---|---|---|
| IPsec | L3 | Network-layer packet protection |
| WireGuard | L3 | Encrypted IP tunnels between peers over UDP |
| TLS | L6, conceptually | Encrypted communication, integrity, and typically server authentication |
| mTLS | L6, conceptually | Encrypted communication with mutual peer authentication |

In Kubernetes, Cilium can provide transparent encryption using IPsec or WireGuard, while Istio can provide service-to-service mTLS. These controls protect traffic at different levels and can complement one another.

## 4. Key takeaways

- **L3 — Network:** Workload identity-based connectivity and network segmentation.
- **L4 — Transport:** TCP/UDP and port restrictions.
- **L5 — Session:** Establishing, maintaining, and managing communication sessions, conceptually.
- **L6 — Presentation:** TLS and mTLS encryption and authentication, conceptually.
- **L7 — Application:** HTTP, gRPC, API authorization, request filtering, and token-based authentication.

> **Architectural note:** These are practical OSI associations, not strict protocol classifications. TLS sits between the transport and application protocols in typical TCP/IP stacks. Modern application sessions are often managed at L7. Cilium workload identities are derived from labels and can be used across policy layers; they are not themselves an L3 protocol. AWS STS issues temporary credentials, which are commonly used to sign AWS API requests with Signature Version 4.
