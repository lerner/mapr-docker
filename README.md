# mapr-docker
Docker environment to build containers, and run a multi-node MapR cluster on a single docker host.

Build docker images

1. In top level directory, download CentOS versions of MapR Core and MapR MEPs that will be used for created images.  For example, to build images for MapR 6.0.1 and 6.1 with MEP versions 5.0.3, 6.0.2, 6.1.1, and 6.2.0
   - curl -O http://package.mapr.com/releases/MEP/MEP-6.2.0/redhat/mapr-mep-v6.2.0.201905272218.rpm.tgz
   - curl -O http://package.mapr.com/releases/MEP/MEP-6.1.1/redhat/mapr-mep-v6.1.1.201905272229.rpm.tgz
   - curl -O http://package.mapr.com/releases/MEP/MEP-6.0.2/redhat/mapr-mep-v6.0.2.201905272240.rpm.tgz
   - curl -O http://package.mapr.com/releases/MEP/MEP-5.0.3/redhat/mapr-mep-v5.0.3.201905272251.rpm.tgz
   - curl -O http://package.mapr.com/releases/v6.1.0/redhat/mapr-v6.1.0GA.rpm.tgz
   - curl -O http://package.mapr.com/releases/v6.0.1/redhat/mapr-v6.0.1GA.rpm.tgz


2. Update the supportedVersArr in the script mapr-centos7/create_version_files.sh per notes in that file to ensure downloaded software versions are properly reflected as supported MapR core and MEP versions.

3. cd to the mapr-centos7 directory and run ./build_all_versions.sh

Run a MapR cluster.  The scripts can use docker volumes but block devices on the docker host are prefered, one for each cluster node. 

1. cd to mapr-centos7/launch-cluster

2. Run launch-five.sh for a sample 5 node cluster.  This script invokes the real launcher script, launch-cluster.sh, which runs all the necessary docker containers.  The launcher container is a mapr client that completes installation and configuration steps by running the start-cluster.sh and start-cluster-[other,custom].sh scripts that are found in mapr-centos7/launch-cluster/[base,sparkhive] or other directories specified with the -C option to launch-cluster.sh

Connect to the MCS GUI

The scripts run a squid web proxy container which provides a mechanism for a remote browser to access all cluster nodes.   I set the proxy in Firefox to the external IP address of the hosting server with port 3128.  Look for a line similar to this after launch-cluster.sh has started the mapr cluster and use credentials mapr/mapr:
```
Sat Jun 22 13:49:58 PDT 2019: SUCCESS:  MapR Control System GUI accessible at https://mapr02.mapr.local:8443 using browser proxy ec2-34-210-106-33.us-west-2.compute.amazonaws.com:3128
```
Connect to cluster nodes
All cluster nodes are running ssh with the launcher client node exposing ssh on port 2222.  After successful startup, you'll see an ssh command to log in as root to the client node with password mapr.  From there you can log in to any cluster node with ssh keys that are already installed.  Clush is also configured for use.
