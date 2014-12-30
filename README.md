chef_lvm_mount
==============

Create an LVM volume, format it and mount it.

* Written to avoid trashing any existing data, but given 
the nature of the tasks, use of this cookbook is absolutely
at your own risk (read the MIT License!).

* Includes a method to automatically select physical disks
based upon a name prefix and a disk count limit.

"It works for me" - If it doesn't work for you: fork it, change it, test it, submit pull request ;)
