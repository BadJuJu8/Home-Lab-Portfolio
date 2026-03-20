### Summary
This phase introduced centralized visibility into the homelab by deploying Splunk as the SIEM and log analysis platform. Up to this point, the environment could be administered, but it could not be observed in a meaningful security focused way. Adding Splunk changed the lab from a functioning infrastructure into an environment that could support monitoring, investigation, and early detection engineering.
### Objectives
- Deploy Splunk as the centralized logging platform
- Ingest security relevant logs from core infrastructure systems
- Establish a usable logging pipeline before expanding into deeper detections
- Bring Windows telemetry into Splunk using Universal Forwarders
- Structure Windows log ingestion in a way that would support search and analysis
- Build an initial security detection to validate the monitoring stack
### Environment / Design
After building out Proxmox, OPNsense, Active Directory, VLAN segmentation, Group Policy, file services, and Linux systems, the next major gap in the lab was visibility. I deployed Splunk on the Ubuntu 22.04.5 LTS system so the environment would have a central platform for collecting, searching, and analyzing events from multiple systems.

I started with **firewall logs** as the first ingested data source. That was a practical place to begin because the firewall sits at a key control point in the environment and provides immediate visibility into network level activity. Once that pipeline was working, I expanded into Windows telemetry using **Universal Forwarders** from the start.

For Windows log ingestion, I also had to structure the incoming data so it would be useful. That included creating a file to separate Windows events into:

- **Application**
- **Security**
- **System**

This phase was important because it introduced the idea that collecting logs is not enough. The data has to be organized well enough to support meaningful searches, detections, and investigations.

### Challenge
The biggest challenge in this phase was not installing Splunk itself. It was getting logs to arrive correctly and in a usable format.

I had to work through several pieces of the telemetry pipeline at once:

- getting devices to send logs to Splunk
- configuring Universal Forwarders correctly
- separating Windows event categories in a structured way
- allowing logging traffic through the firewall in a segmented network

This made it clear that a SIEM does not create visibility automatically. In a segmented environment, even security monitoring traffic depends on proper routing, firewall rules, and source configuration. If any of those pieces are wrong, the data either never arrives or arrives in a way that is difficult to use.

### Actions Taken

- Deployed Splunk on Ubuntu 22.04.5 LTS
- Began by ingesting firewall logs to establish the first working logging pipeline
- Used Universal Forwarders on Windows systems from the beginning
- Configured structured Windows ingestion for Application, Security, and System logs
- Adjusted firewall behavior so telemetry could successfully reach Splunk
- Built an early detection for repeated failed logon attempts

### Results / Key Takeaways
By the end of this phase, the homelab had a functioning centralized logging platform with firewall telemetry flowing into Splunk and Windows systems forwarding host based events in a more structured way. More importantly, the lab moved beyond passive logging and into early detection engineering with a rule designed to identify **five unsuccessful login attempts within five minutes**.

This phase taught me that a SIEM is only as useful as the quality, structure, and flow of the data it receives. It also showed me that visibility is an engineering problem, not just a tooling problem. Forwarders, log source structure, and network permissions all have to work together before detection engineering becomes meaningful.

> **Key takeaway:** This was the phase where the homelab stopped being only an admin environment and started becoming a security monitoring and investigation platform.