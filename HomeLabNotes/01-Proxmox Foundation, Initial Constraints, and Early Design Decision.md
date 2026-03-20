## Summary  
This phase established the virtualization foundation of the homelab using Proxmox VE. The main challenge was working within limited hardware resources while still creating a platform capable of supporting a realistic multi VM environment.  
  
## Objectives  
- Deploy Proxmox as the base hypervisor  
- Create the initial VM plan  
- Evaluate hardware limits before expanding the lab  
  
## Environment  
- **CPU:** Intel Core i9-11900K  
- **GPU:** NVIDIA RTX 3070  
- **RAM:** 16 GB initially  
- **Disk:** 256 GB  
- **Hypervisor:** Proxmox VE  
  
## Initial VM Plan  
- OPNsense firewall/router  
- Windows client  
- Active Directory server  
  
## Challenge  
The system had enough CPU power for virtualization, but RAM and storage quickly became constraints. This forced tighter VM sizing, limited growth, and made it clear that the lab would need to be built in phases.  
  
## Actions Taken  
- Kept the environment intentionally small at first  
- Planned storage more carefully  
- Upgraded RAM to support later expansion  
  
## Results  
- Proxmox deployed successfully  
- Initial VM plan defined  
- Resource constraints identified early  
- Virtualization foundation established for later networking and domain services  
  
## Key Takeaways  
> RAM and storage, not CPU, became the first major bottlenecks in the homelab.  
  
> This phase taught me to approach the lab as real infrastructure with finite capacity, not just a place to spin up random VMs.  
  
