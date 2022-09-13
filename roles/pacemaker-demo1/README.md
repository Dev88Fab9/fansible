pacemaker-demo
=========
Demo role to deploy a pacemaker / corosync Web Apache cluster
Two nodes only

Requirements
------------
None besides ansible pre-requisites


Role Variables
--------------
Currently STONITH is disabled, you can set it to true in the default settings
But no STONITH configuration is yet done, this would be up to you to implement
if you want.


Dependencies
------------
There are currently no dependences


Example Playbook
----------------
To test the playbook go to the tests directory and execute the script run.sh
In this way:
run.sh -a CREATE
Without the correct option the script won't run. This is to avoid accidental
systems modifications.

Likewise the script tests/rollback/rollback.sh requires the option
-a DESTROY in order to destroy the cluster and undo any modification.
It is not a true rollback of course, as any other activity that might have
occurred in the system won't be undone. If you other better rollback ways in
place I suggest to use that, for instance, through VMWare snapshots.


License
-------
GPL v2
https://opensource.org/licenses/gpl-2.0.php


Author Information
------------------
Fabrizio Pani
