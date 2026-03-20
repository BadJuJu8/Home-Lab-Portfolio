### Summary
This phase focused on turning Active Directory from a working domain into a manageable directory structure. I built a corporate style OU layout, organized users and workstations by department, introduced naming standards, and used scripting to provision users at scale. This was the phase where the lab started becoming administratively useful instead of just operational.

### Objectives

- Build an OU structure that resembled a real corporate environment
- Organize users, workstations, servers, and groups in a scalable way
- Create department based structure for future policy and access control
- Establish naming conventions for users, workstations, and servers
- Populate the environment with enough user accounts to support realistic testing
- Prepare the directory for future Group Policy and delegated administration

### Environment / Design
Once Active Directory and DNS were working, the next step was directory organization. A functioning domain alone is not enough if users, groups, computers, and servers are left in default containers or placed inconsistently. I wanted the domain to look intentional from the start, so I created a structured OU hierarchy under a top level `Corp` OU.

The early OU design was effectively the same structure I kept long term, with the later addition of a `Disabled` OU once I started working more seriously on joiner, mover, leaver processes. The core layout included dedicated OUs for:

- `Admin`
- `Groups`
- `Servers`
- `Users`
- `Workstations`

Users and workstations were further divided by department. I created the departmental structure immediately rather than waiting until later. The main departments were:

- Engineering
- Finance
- HR
- IT
- Sales

This design supported one of the main goals of the lab from the beginning, which was structured Group Policy. By separating users and workstations by department, I created clean targets for later GPO scoping, access control, and system organization.

I also introduced naming standards during this phase:

- **Users:** `first.last`
- **Workstations:** department and system based naming
- **Servers:** functional abbreviations

To make the environment more realistic, I used scripting to create 50 users across the five departments instead of building the directory by hand one account at a time.

### Challenge

The main challenge in this phase was architectural, not operational.

There was no major outage or obvious failure. The real work was designing an OU structure that would make sense not just in the moment, but as the lab grew. I had to think about how the directory would support future Group Policy, user placement, workstation organization, and access control decisions. If the structure was weak at this stage, every later phase would become harder to manage.

I also needed a way to populate the domain realistically. A handful of test users would not be enough to meaningfully test group membership, OU placement, login behavior, or later resource access. That meant the directory needed scale as well as structure.

### Actions Taken

- Built a structured OU hierarchy under `Corp`
- Created department based OUs from the beginning instead of postponing organizational design
- Separated users, workstations, servers, groups, and admin objects into dedicated locations
- Established naming standards for users, workstations, and servers
- Used scripting to create 50 users across five departments
- Designed the structure with future Group Policy and access control in mind
### Results / Key Takeaways

By the end of this phase, the homelab had a clean and scalable Active Directory structure with departmental organization, predictable naming, and enough users to support realistic administration and testing. The directory was no longer just technically functional. It was organized in a way that supported management, policy scoping, and future growth.

This phase taught me that directory structure is not just visual organization. It is the management layer that later controls depend on. Good OU design makes Group Policy, access control, and administration easier. Poor design makes everything harder.

> **Key takeaway:** This was the phase where Active Directory stopped being just a domain and started becoming a structured management platform.