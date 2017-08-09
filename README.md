# PNDA DIB Elements

Deploying PNDA using Heat templates requires an image with some pre-installed elements, such as `os-collect-config`. This guide describes how to build such an image from a set of external disk-image-builder elements.

PNDA currently uses the Ubuntu operating system, but you can use Ubuntu or Centos OSes to create the PNDA image.

## Pre-requesites

**Important:** these dependencies install correctly on an Ubuntu 14.04 *server* image but fail on a *desktop* images.

If you are on Ubuntu:
```
sudo apt-get -y install python-pip python-dev qemu-utils libguestfs-tools kpartx
```

If you are on Centos:
```
sudo yum install epel-release
sudo yum install python-pip python-devel libguestfs-tools
```

## Setting up a virtualenv

Install virtualenv:

```
pip install --user virtualenv
```

Create the virtual environment:

```
virtualenv /path/to/project/pnda-dib
. /path/to/project/pnda-dib/bin/activate
```

## Getting the required elements

Update submodules:
```
git submodule init
git submodule update
```

Install `openstack/diskimage-builder`:

```
cd dib-utils
python setup.py install
cd ..
cd diskimage-builder
python setup.py install
cd ..
pip install six
pip install PyYAML
```

## Ubuntu configuration file
Set up environment variables, assuming you currently are in this repository's project directory (there is at least a elements directory present):

```
cat > dib_env.sh <<EOF
export ELEMENTS_PATH=tripleo-image-elements/elements:heat-templates/hot/software-config/elements:elements

# For Ubuntu base image
export BASE_ELEMENTS="ubuntu"
export DIB_RELEASE=trusty
# USE AN ALTERNATE UBUNTU MIRROR
# export DIB_DISTRIBUTION_MIRROR="http://[MIRRORIP]/ubuntu"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"

# NON MANDATORY ELEMENTS FOR PNDA PROVISIONING
# but might be helpful if you plan to use anible, saltstack or puppet
# export DEPLOYMENT_TOOL="heat-config-ansible heat-config-salt heat-config-puppet"
# PNDA ELEMENTS


# You can specify other pnda-specific elements in the PNDA_ELEMENTS variable:
# for example, 'pnda-disable-ipv6', 'pnda-bond0' or 'os-hardening'
# Please look inside the elements directory

# If you are using 'os-hardening' element uncomment the following line
# export ANSIBLE_VERSION=2.2.1.0

export PNDA_ELEMENTS="cloud-init-pnda"
export IMAGE_NAME=pnda-image
export ALL_ELEMENTS="\$BASE_ELEMENTS \$AGENT_ELEMENTS \$DEPLOYMENT_BASE_ELEMENTS \$DEPLOYMENT_TOOL \$PNDA_ELEMENTS"

EOF
. dib_env.sh
```

## RHEL configuration file
Set up environment variables, assuming you currently are in this repository's project directory (there is at least a elements directory present):


### Online subscription

NOTICE: for more information related to RHEL installation, go to [RHEL7 diskimage builder docs](https://docs.openstack.org/developer/diskimage-builder/elements/rhel7/README.html)
Please set the REG_USER and REG_PASSWORD used for registering and building the base image. PNDA_RHEL_REG_USER and PNDA_RHEL_REG_PASSWORD are used for registering all the deployed images using Heat. Refer to [RHEL common documentation for diskimage builder](https://docs.openstack.org/developer/diskimage-builder/elements/rhel-common/README.html)

```
cat > dib_env.sh <<EOF
source ./license.sh
export ELEMENTS_PATH=tripleo-image-elements/elements:heat-templates/hot/software-config/elements:elements
export BASE_ELEMENTS="rhel7"
export DIB_LOCAL_IMAGE=rhel-guest-image-7.3-35.x86_64.qcow2
export REG_METHOD=portal
export REG_USER=<user>
export REG_PASSWORD=<password>
export PNDA_RHEL_REG_USER=<user>
export PNDA_RHEL_REG_PASSWORD=<password>
export REG_REPOS='rhel-7-server-optional-rpms,rhel-7-server-extras-rpms'
export REG_AUTO_ATTACH=true 
export PNDA_RHEL_ELEMENTS="pnda-rhel-registration"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"

# NON MANDATORY ELEMENTS FOR PNDA PROVISIONING
# but might be helpful if you plan to use anible, saltstack or puppet
# export DEPLOYMENT_TOOL="heat-config-ansible heat-config-salt heat-config-puppet"
# PNDA ELEMENTS


# You can specify other pnda-specific elements in the PNDA_ELEMENTS variable:
# for example, 'pnda-disable-ipv6', 'pnda-bond0' or 'os-hardening'
# Please look inside the elements directory

# If you are using 'os-hardening' element uncomment the following line
# export ANSIBLE_VERSION=2.2.1.0

export PNDA_ELEMENTS="cloud-init-pnda"
export IMAGE_NAME=pnda-image
export ALL_ELEMENTS="\$BASE_ELEMENTS \$AGENT_ELEMENTS \$DEPLOYMENT_BASE_ELEMENTS \$DEPLOYMENT_TOOL \$PNDA_ELEMENTS \$PNDA_RHEL_CONFIGURATION \$PNDA_RHEL_ELEMENTS"

EOF
. dib_env.sh
```

### Offline subscription

In case you want to setup a PNDA in an offline environment, you need then to follow the offline registration describe here:[RHEL offline registration documentation](https://docs.openstack.org/developer/diskimage-builder/elements/rhel-common/README.html).

You will need to generate certificates for all your cluster instances, so then for a pico cluster with 1 data node and 1 kafka node and a cluster name pnda-offline, you will need 6 certificates and each one need CPU information as describe on the [platform requirement on Heat](https://github.com/pndaproject/pnda-guide/blob/develop/provisioning/platform_requirements.md#heat):
pnda-offline-bastion.novalocal.pem
pnda-offline-kafka-0.novalocal.pem
pnda-offline-cdh-dn-0.novalocal.pem
pnda-offline-cdh-mgr1.novalocal.pem
pnda-offline-cdh-edge.novalocal.pem
pnda-offline-saltmaster.novalocal.pem

Once you have them, you will need to put them on the PNDA Mirror in folder called certificates.

```sh
mkdir certificates
mv *.pem certificates/
cp -r certificates /var/www/html
```

That's why you have a PNDA_MIRROR environment variable defined in the script bellow, which need to set as PNDA_MIRROR=http://x.x.x.x 

```
cat > dib_env.sh <<EOF
source ./license.sh
export ELEMENTS_PATH=tripleo-image-elements/elements:heat-templates/hot/software-config/elements:elements
export BASE_ELEMENTS="rhel7"
export DIB_LOCAL_IMAGE=rhel-guest-image-7.3-35.x86_64.qcow2
export REG_METHOD=portal
export REG_USER=<user>
export REG_PASSWORD=<password>
export PNDA_MIRROR=<pndaMirrorURI>
export REG_REPOS='rhel-7-server-optional-rpms,rhel-7-server-extras-rpms'
export REG_AUTO_ATTACH=true 
export PNDA_RHEL_ELEMENTS="pnda-rhel-offline-registration"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"

# MANDATORY ELEMENTS FOR PNDA PROVISIONING
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"

# NON MANDATORY ELEMENTS FOR PNDA PROVISIONING
# but might be helpful if you plan to use anible, saltstack or puppet
# export DEPLOYMENT_TOOL="heat-config-ansible heat-config-salt heat-config-puppet"
# PNDA ELEMENTS


# You can specify other pnda-specific elements in the PNDA_ELEMENTS variable:
# for example, 'pnda-disable-ipv6', 'pnda-bond0' or 'os-hardening'
# Please look inside the elements directory

# If you are using 'os-hardening' element uncomment the following line
# export ANSIBLE_VERSION=2.2.1.0

export PNDA_ELEMENTS="cloud-init-pnda"
export IMAGE_NAME=pnda-image
export ALL_ELEMENTS="\$BASE_ELEMENTS \$AGENT_ELEMENTS \$DEPLOYMENT_BASE_ELEMENTS \$DEPLOYMENT_TOOL \$PNDA_ELEMENTS \$PNDA_RHEL_CONFIGURATION \$PNDA_RHEL_ELEMENTS"

EOF
. dib_env.sh
```

## Build the image

```
disk-image-create vm $ALL_ELEMENTS -o $IMAGE_NAME.qcow2
```

## Upload the image to the OpenStack infrastructure

Install the glance client:

```
pip install python-glanceclient
```

Upload the image to the OpenStack image service:

```
. your_openstack_rc.sh
glance image-create --name pnda-base --file pnda-image.qcow2 --progress --disk-format qcow2 --container-format bare
```
