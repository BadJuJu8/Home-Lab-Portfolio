### Summary
This phase expanded the homelab from a Windows focused environment into a mixed platform environment by introducing Ubuntu systems for administration and security tooling. Adding Linux made the lab more realistic and forced me to deal with cross platform networking, trust, and identity challenges that do not appear in Windows only environments.
### Objectives
- Add Linux systems to make the environment more representative of real infrastructure
- Build a Linux based administrative workstation
- Deploy a Linux based host for security tooling
- Work through inter VLAN communication for management systems
- Explore Linux integration with Active Directory
- Increase the realism of the lab by supporting mixed Windows and Linux operations
### Environment / Design
As the homelab matured, it became clear that a realistic enterprise environment could not remain Windows only. I introduced two Ubuntu systems with different roles:

- **Ubuntu 24.04.2 LTS** as the **NetAdmin** system
- **Ubuntu 22.04.5 LTS** as the **Splunk** host

The NetAdmin system gave me a Linux based administrative workstation inside the segmented lab. The Splunk host positioned Linux as part of the future security monitoring architecture. Together, these systems moved the lab beyond pure Windows administration and closer to the kind of mixed platform environment found in real organizations.

This phase was important because Linux was not added as a side experiment. It became part of both the administrative plane and the security tooling stack.

### Challenge
The biggest early challenge was getting the NetAdmin system to communicate correctly across VLANs.

By this point, the environment was already segmented, which improved security but made administration more complex. The NetAdmin system needed to reach resources in other VLANs to actually serve its purpose, so I had to think carefully about how administrative traffic should move through a segmented environment. That forced me to confront a more realistic infrastructure problem: management access has to be allowed intentionally without collapsing the trust model of the network.

A later challenge came when I attempted to join the Ubuntu NetAdmin system to the domain. That exposed a different class of problem. Linux to Active Directory integration was not just about credentials or basic connectivity. It involved trust, certificate handling, name resolution, and the assumptions each platform makes about identity. Certificate trust between Ubuntu and the domain became a major point of friction during the integration effort.

### Actions Taken
- Deployed Ubuntu 24.04.2 LTS as the NetAdmin system
- Deployed Ubuntu 22.04.5 LTS as the Splunk host
- Used the NetAdmin system to work through administrative access across segmented VLANs
- Treated Linux systems as first class infrastructure components rather than isolated test systems
- Attempted to integrate Ubuntu with Active Directory
- Identified certificate trust as a real dependency in cross platform identity integration

### Results / Key Takeaways
By the end of this phase, the homelab had evolved into a mixed Windows and Linux environment. Linux now played a role in both administration and security operations, which increased the realism and depth of the environment. This phase also introduced more advanced troubleshooting around segmented management access, cross platform trust, and Linux domain integration.

This phase taught me that real infrastructure is rarely single platform. It also showed me that mixed environments create a different class of problem than Windows native administration alone. Once Linux, segmentation, and identity integration overlap, troubleshooting becomes much more about trust, dependencies, and interoperability.

> **Key takeaway:** This was the phase where the homelab stopped being a Windows only admin environment and started becoming a more realistic mixed platform infrastructure.