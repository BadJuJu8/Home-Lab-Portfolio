### Summary
This phase established the first real network control layer of the homelab by deploying OPNsense as the primary router and firewall. Until this point, the lab had a virtualization platform but no intentional traffic control. Adding OPNsense changed the environment from a small collection of VMs into a routed network where connectivity had to be designed and enforced.

### Objectives

- Deploy OPNsense as the lab’s router and firewall
- Provide internet access to the client machine
- Allow the client to communicate with the domain controller
- Build a functional network foundation before moving into VLAN segmentation
- Begin learning how firewall rules, interfaces, and routing affect system communication

### Environment / Design
I chose OPNsense as the router and firewall from the start. I had previously worked with pfSense in another lab, so I wanted to build familiarity with a similar but different platform and gain hands on experience with a firewall appliance I could potentially apply to my home network as well.

The design at this stage was intentionally simple. I was not trying to build a highly segmented enterprise network yet. The immediate goal was to create a basic routed environment where a client could reach the internet and also communicate with the Active Directory server well enough to support authentication and future Group Policy use. VLANs and deeper segmentation came later. At this stage, the focus was basic functionality and controlled connectivity.

OPNsense became the central traffic control point for the lab. That made it more than just another virtual machine. It became the system responsible for deciding how traffic moved between systems and what communication was allowed.

### Challenge
The biggest challenge in this phase was not deploying OPNsense itself. It was learning how to think about firewall behavior in a deliberate way.

At first, my understanding of firewall rules and best practices was still limited. I did not yet have a strong sense of what should be explicitly allowed, what should be denied, or how strict a firewall policy should be even in a lab setting. That made it difficult to move beyond a simple “make it work” approach into something more intentional and security minded.

I also had to begin understanding how routing, interfaces, and firewall rules affected communication between the client and the domain controller. Even in a simple environment, it became clear that network connectivity is easy to assume and harder to understand once a firewall is responsible for enforcing it.

### Actions Taken

- Deployed OPNsense as the dedicated router and firewall for the lab
- Used OPNsense as the central point of control instead of relying on default unmanaged VM networking
- Focused first on establishing stable connectivity for the minimum viable lab
- Worked through firewall concepts hands on by testing connectivity and learning how rule behavior affected communication
- Kept the network design simple at this stage so I could build a stronger foundation before introducing segmentation

### Results / Key Takeaways
By the end of this phase, OPNsense was functioning as the primary router and firewall for the environment. The lab now had a real network control layer instead of loosely connected VMs, and that created the base needed for later VLAN segmentation, traffic isolation, and stronger security design.

This phase taught me that a firewall appliance is not just there to provide internet access. It is a security control point that defines how systems are supposed to interact. It also showed me that functional connectivity is only the beginning. Real network design starts when traffic becomes intentional instead of assumed.

> **Key takeaway:** This was the phase where the homelab stopped being just a virtualization setup and started becoming an actual networked environment.