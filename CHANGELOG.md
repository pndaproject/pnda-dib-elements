# Change Log
All notable changes to this project will be documented in this file.

## [0.2.0] 2017-05-23
### Added
- PNDA-2741: New element to disable IPv6
- PNDA-2742: New element to bond eth0 and eth1 together
- PNDA-2780: New element executing https://github.com/dev-sec/ansible-os-hardening ansible role
- PNDA-2733: Add support for RHEL 

### Changed
- Disable password expiration in os-hardening element

## [0.1.2] 2016-12-12
### Changed
- Moving bootloader element to elements directory

## [0.1.1] 2016-10-21
### Added
- Instructions to build a PNDA image from CentOS
- TripleO and heat-templates repositories as sub-modules
- A new environment variable to specify an alternate Ubuntu mirror
- A new element to fix network interfaces naming

### Fixed
- sed command to update Cloud-init configuration file

## [0.1.0] 2016-07-01
### First version
- Tools for creating PNDA images
