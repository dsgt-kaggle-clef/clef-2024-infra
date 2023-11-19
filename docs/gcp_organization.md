# GCP Organization

How are resources organized in GCP?
This document will try to explain the structure of the configuration in the `clef-2024-infra` repository.
We use terraform to manage the resources, and ansible to configure them.

## Organization

We provision a VM per team, that is accessible only to users that are part of that team.
The VM can be modified by the team, and is likely to change in size or physical configuration over the course of the competition.
We try to use pre-emptible VMs where possible, to reduce costs.
We also try to minimize the use of persistent disk, which costs us $0.14/GB/month.
We add scratch disk to the VMs, which come in 350GB increments, and cost us only when the VM is one.
On the other hand, the scratch disk disappears, which means that we need to sync the resources with it's backing bucket often.

There is a default public bucket that is accessible to all users, and shared by all teams.
Each team also has their own namespaced bucket that is accessible to users of that team.

We also provision a centralized scheduler for luigi so that we can parallelize tasks across multiple VMs.
This scheduler is accessible to all users, and is used to run the tasks that are common to all teams.
