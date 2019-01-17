# IPFS Install Script

Just a simple bash script I made to set up an IPFS easilly on Linux Ubuntu 18.04 (and later)

Not tested 100% yet, **use at your own risk**

The script will: 
- get the last version available of IPFS
- connect to the online package repo for that version
- download the linux amd version
- install it
- make it run as a service using **systemctl**
