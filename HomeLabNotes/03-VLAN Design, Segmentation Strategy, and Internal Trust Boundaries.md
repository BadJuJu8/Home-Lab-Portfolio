### Summary
This phase transformed the homelab from a basic routed environment into a segmented network designed more like a corporate infrastructure. I introduced VLANs to separate systems by function and reduce the risks of a flat network. This was the point where the lab started reflecting security architecture rather than just connectivity.

### Objectives

- Introduce internal network segmentation using VLANs
- Separate systems by role instead of keeping everything on one flat network
- Reduce the risk of easy lateral movement between systems
- Build a more realistic enterprise style trust model
- Learn how routing and firewall policy affect communication between segmented networks
### Environment / Design
As the homelab expanded, I stopped thinking of it as a small project and started designing it more like a corporate environment. The main reason for this change was security. In my studies, I kept seeing the same lesson repeated: flat networks make lateral movement much easier after compromise. I wanted the environment to reflect the idea that infrastructure, users, administration, and security tooling should not all share the same trust level.

Instead of adding VLANs randomly over time, I created the major network segments I expected the lab to need from the start. Each VLAN had a specific role, subnet, and gateway. This made the network cleaner to manage and easier to reason about both operationally and from a security perspective.

|VLAN ID|Name|Subnet|Gateway|Purpose|
|---|---|---|---|---|
|10|Servers|10.10.0.0/24|10.10.40.1|Domain controller, file server, and infrastructure systems|
|20|Endpoints|10.20.0.0/24|10.20.40.1|User workstations|
|50|NetAdmin|10.50.0.0/24|10.50.40.1|Administrative workstation|
|60|SecTools|10.60.0.0/24|10.60.40.1|Security tools and monitoring systems|

This design created clearer internal trust boundaries. Infrastructure systems lived in the server network, user systems were isolated in the endpoint network, administration had its own segment, and security tools were placed separately so they could later support monitoring without living in the same trust zone as everything else.

### Challenge
The biggest challenge in this phase was not creating the VLANs themselves. The difficult part was understanding how segmented systems should communicate with each other once they were separated.

In a flat network, communication feels automatic. After segmentation, nothing meaningful works unless routing and firewall rules are configured intentionally. I had to start thinking in terms of dependencies. Endpoints still needed to reach DNS and domain services in the server VLAN. Administrative systems needed access to manage infrastructure. Security tools eventually needed enough visibility to monitor the environment without becoming unrestricted backdoors.

That was a major shift. I could no longer ask whether a machine simply had network access. I had to ask which systems should communicate, across which VLANs, and for what purpose. I also had to work through early uncertainty around how to allow required traffic without making segmentation meaningless by opening everything up.

### Actions Taken

- Introduced VLANs based on system function instead of adding networks randomly
- Assigned dedicated subnets and gateways for each network segment
- Separated infrastructure, user endpoints, administrative systems, and security tooling into distinct trust zones
- Began treating inter VLAN communication as a deliberate design decision
- Used segmentation to make network dependencies and trust relationships more visible
### Results / Key Takeaways

By the end of this phase, the lab had evolved from a simple routed setup into a segmented internal network with clearly defined zones. Communication was no longer assumed by default. It had to be designed and justified. This made the environment more secure, more realistic, and much closer to the type of architecture used in actual organizations.

This phase taught me that VLANs are not just a way to organize addresses. They are a security control. Segmentation only becomes valuable when it forces you to think about trust boundaries, least privilege, and dependency mapping.

> **Key takeaway:** This was the phase where the network stopped being just transport and started becoming architecture.
