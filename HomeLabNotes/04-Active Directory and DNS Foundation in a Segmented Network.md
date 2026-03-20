### Summary

This phase introduced centralized identity and management into the homelab by deploying a Windows Server domain controller and creating the domain `RobsLab.local`. It marked the point where the environment stopped being just a network of connected systems and started functioning like a real Windows enterprise environment.

### Objectives

- Deploy Active Directory as the central identity service
- Create a functional Windows domain for the lab
- Use DNS to support internal name resolution and domain services
- Establish the foundation for Group Policy and centralized administration
- Ensure clients could join the domain and still reach external resources when needed

### Environment / Design

Once the network foundation and early routing were in place, the next step was centralized identity. I deployed a Windows Server domain controller and created the domain `RobsLab.local` to serve as the backbone of the environment.

The goal was not just authentication. One of the main reasons for introducing Active Directory was to support hands on work with Group Policy and to start building a more structured management model. Without a domain, there would be no realistic way to manage users, computers, policies, and administrative behavior across multiple systems in a way that resembled a business environment.

The domain controller also handled DNS for the internal environment. That made DNS a critical dependency, because Active Directory relies heavily on correct name resolution. At this point, the domain controller was serving as both the identity platform and the internal naming service that the rest of the Windows environment depended on.

### Challenge
The biggest issue in this phase was DNS, specifically the gap between internal and external name resolution.

Domain join worked immediately, which suggested that Active Directory and internal DNS were functioning correctly. However, systems in the lab were not getting internet connectivity as expected. That made the issue less obvious at first, because some domain related functions were already working. The problem turned out to be that internal DNS resolution existed, but external name resolution was incomplete because DNS forwarders had not yet been configured.

This created an important troubleshooting lesson. A domain can appear operational while still having a serious DNS design problem underneath it. In this case, internal name resolution supported the domain, but requests for names outside the local environment were not being handled properly.

### Actions Taken

- Deployed a Windows Server domain controller for the `RobsLab.local` domain
- Used the domain controller as the internal DNS server for the environment
- Verified that domain join was functioning correctly
- Identified DNS as the source of the internet connectivity issue
- Configured DNS forwarders so external DNS requests could be passed to an upstream resolver
- Restored outside name resolution while preserving internal domain DNS functionality

### Results / Key Takeaways
By the end of this phase, the homelab had a functioning Active Directory domain, working internal DNS for domain services, successful domain join capability, and corrected external name resolution through DNS forwarders. More importantly, the lab now had the base platform required for centralized policy driven administration.

This phase taught me that Active Directory is not just a user login system. It is a critical management platform, and DNS is one of the services that makes the whole environment stable or unstable depending on how it is configured.

> **Key takeaway:** This was the phase where the lab gained centralized identity, but it also made it clear that in Windows environments, DNS is not optional plumbing. It is core infrastructure.