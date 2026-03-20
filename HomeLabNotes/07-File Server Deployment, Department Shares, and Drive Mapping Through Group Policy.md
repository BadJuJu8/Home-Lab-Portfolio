### Summary
This phase added a practical business resource to the homelab by deploying a departmental file server and using Group Policy to deliver mapped drives to users automatically. It connected identity, access control, and user experience into one working system, making the environment feel much more like a real organization.
### Objectives
- Deploy a file server to host shared departmental resources
- Create one share per department
- Control access through department based Active Directory groups
- Use Group Policy to map the correct drives to the correct users
- Validate that identity, permissions, and policy were working together correctly
- Make the environment reflect a more realistic business use case

### Environment / Design
Once the domain, OU structure, users, groups, and baseline GPOs were in place, the next step was adding a shared business resource that users would actually depend on. I deployed the file server `FS-01` and designed it to host one share per department.

The access model was built around department aligned group membership. Instead of assigning permissions directly to individual users, departmental groups were granted access to their corresponding shares. The goal was for users to sign in and automatically receive mapped drives that matched their department and only their department.

This phase was important because it made the access design visible. Before this point, department groups and user organization mostly existed as directory structure. With `FS-01` in place, those groups now directly controlled access to business style resources, which made the identity model much more concrete and testable.

### Challenge
The biggest challenge in this phase was drive mapping.

The desired outcome sounded simple: users should log in and automatically receive the correct departmental drives. In practice, though, mapped drives depend on several layers working together correctly at the same time. The share paths, permissions, GPO configuration, user scope, and policy processing all had to align. When the mappings did not work correctly at first, troubleshooting became more complex than expected.

This was one of the more valuable troubleshooting phases in the lab because it showed that drive mapping is not just a convenience feature. It is the visible result of identity, permissions, and policy all operating correctly together. A problem in any one of those layers can break the outcome for the user.

### Actions Taken
- Deployed `FS-01` as the departmental file server
- Created one share per department
- Used department based groups for access control instead of direct user level permissions
- Built drive mappings through Group Policy so users would receive resources automatically at logon
- Refined the mapping configuration until departmental users received only the drives intended for them
- Validated that access matched department membership and assigned permissions correctly

### Results / Key Takeaways
By the end of this phase, users could sign in and automatically receive the department specific mapped drives intended for them, with access limited to the resources granted through group membership. This proved that the earlier identity and policy work was functioning end to end.

This phase taught me that file access in Windows environments depends on more than just creating a share. The final user experience depends on Active Directory structure, group membership, share permissions, NTFS permissions, and Group Policy all working together. It also reinforced that group based access control is much more scalable and maintainable than direct user by user assignment.

> **Key takeaway:** This was the phase where the homelab’s identity design became a real access model that users could experience directly.