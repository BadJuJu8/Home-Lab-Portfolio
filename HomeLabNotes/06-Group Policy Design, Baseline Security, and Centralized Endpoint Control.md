# Summary
This phase turned the domain from a structured identity environment into a centrally managed Windows environment. I used Group Policy as the main enforcement layer for security baselines, endpoint behavior, audit settings, update management, and administrative control. This was one of the core goals of the homelab from the beginning.

### Objectives
- Use Group Policy as the central configuration and security enforcement mechanism
- Build baseline policy objects for workstations and servers
- Apply security focused settings in a structured and repeatable way
- Control local administrator access more deliberately
- Create a policy model that could scale as the lab expanded
- Prepare the environment for later user experience policies such as drive mappings

### Environment / Design
Once the OU structure was in place, Group Policy became the next major management layer. This was one of the main reasons I built the lab in the first place. I wanted real hands on experience with GPOs and a place to learn what strong policy standards should look like in a business style Windows domain.

I approached this phase by building a set of baseline controls rather than treating Group Policy like a collection of random one off settings. I created multiple GPOs to separate responsibilities across workstation, server, and role specific configurations. The main areas I focused on early were:

- baseline security
- audit policy
- Microsoft Defender
- Windows Update
- restricted groups
- local administrator control

Later, once the file server existed, I extended the policy model to include drive mappings.

Representative GPOs in the environment included:

- `WKS_BaselineSecurity_MS_v1`
- `WKS_DefenderBaseline_v1`
- `WKS_AuditPolicy_v1`
- `WKS_LocalAdmins_v1`
- `WKS_RestrictedGroups_Admins_v1`
- `WKS_WindowsUpdate_v1`
- `WKS_DriveMaps_v1`
- `SRV_BaselineSecurity_v1`
- `SRV_AuditPolicy_v1`
- `SRV_ServiceAccounts_LogonDeny_v1`
- `DC_CA_v1`
- `Audit_test`

A major design decision in this phase was to keep workstation and server policy separate. That reflected a more realistic enterprise approach, since servers and endpoints should not be managed identically. I also used Group Policy to move toward disabling or tightly controlling local administrator access, which aligned with the security focused direction of the lab.

Some of the baseline thinking was influenced by best practices and by concepts from NIST SP 800-171. The goal was not to claim formal compliance, but to use the lab to understand how security intent can be translated into actual Windows configuration.

### Challenge
The main challenge in this phase was not a single outage or broken policy. It was turning general security ideas into enforceable policy in a clean, scalable way.

I had to decide how to split baseline controls across workstations and servers, how to handle local administrator rights in a way that matched enterprise thinking, and how to harden the environment without making it unnecessarily difficult to operate. I also had to build policy in the right sequence. For example, drive mapping was part of the overall design, but it could not be implemented until the file server existed.

This phase required more architectural thinking than troubleshooting. The real problem was building a policy framework that made sense, not just pushing a few settings into the domain.

### Actions Taken
- Built multiple GPOs as a structured policy framework instead of relying on one generic baseline
- Created separate policy objects for workstation and server management
- Applied baseline security, audit, Defender, Windows Update, and restricted group settings through Group Policy
- Used policy to disable or tightly control local administrator access
- Linked and scoped GPOs using the OU structure built in the previous phase
- Added user environment policies such as drive mappings later, once supporting infrastructure existed
### Results / Key Takeaways
By the end of this phase, Group Policy had become one of the core administrative tools in the homelab. The environment now had centralized enforcement for baseline security, audit settings, endpoint controls, update behavior, and local administrator restrictions. It also had a structure that could support later policy growth without becoming chaotic.

This phase taught me that Group Policy is where a Windows domain starts becoming truly manageable. Authentication gets systems into the environment, but policy is what defines how those systems behave. It also reinforced that good OU design and good GPO design depend on each other.

> **Key takeaway:** This was the phase where the homelab moved from organized identity into centralized control and security enforcement.