Ansible test to deploy a simple two-node cluster with Apache httpd

Please note the following:
1. no precautions with regards to security are yet in place;
   anyway hosts are fictional and they can refer to anybody LAN. Also there 
   are no PII.
2. You need an Ansible controller host plus two nodes running CentOS > 7.x   
2. you need to configure upfront a mutual password-less (key based)
authentication between the two nodes, with the hacluster and the root account


Instructions:
Run run.sh to execute the playbooks in the correct Order
If you need to get rid of the cluster and the Apache HTTPD or if an error
occurs, run rollback.sh
