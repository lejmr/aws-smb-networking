# Amazon AWS Networking Lab

The ultimate goal of this repository is to validate knowleadge of networking in Amazon AWS. As long as I am running my tests from an network without public IPv4 address I had to prepare a 0. lab where I am first preparing the VyOS based VPN hub.

This VPN hub serves as a roundevouz point which serves as a Customer gateway for VPC and clients through PPTP. PPTP is used because it is probably the most simple VPN I know to setup. All you need to have is gateway address, username, and password in order to connect the VPN. Presume that nobody is planning on using this setup for production use.

## Scope of labs

* EC2 and Basic Networking
* VPN networking
* Transit gateways and multi-region setup
* Route 53
* Active directory
* Implementation of CIS


## Organization of this lab

Multiple branches are saved in this git repository each serving as a checkpoint. Hence branch

* 0-lab branch tackles the main network including VPN setup.
* 1-lab branch tackles transit network setup

Each lab has its own directory docs/${BRANCH_NAME} containing static content and further details
