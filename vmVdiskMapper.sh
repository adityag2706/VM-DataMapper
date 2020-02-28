#!/usr/bin/env bash
# Script to get snapshot and vdisk IDs of a VM
# The script uses VM Name as an input; assumes VM Names are unique and do not contain whitespaces
# Needs to be run on Nutanix CVM  as nutanix user obviously :P
# Usage:  ./vmVdiskMapper.sh <VM Name>

# Get VM Name from Input
vmName="$1"

# Get VM UUID from VM Name
vmUuid=`acli vm.list | grep "$vmName" | awk '{print $2}'`
printf 'Uuid for VM %s is %s\n' "$vmName" "$vmUuid"

# Get all the vmdisks (uuids) for the VM
vmDisk=`acli vm.get "$vmUuid" | egrep "\svmdisk_uuid" | awk '{print $2}'`
vmDiskList=( $vmDisk )

# Iterate through the vdisks
for i in "${vmDiskList[@]}"
do
   printf 'vdisk uuid is %s\n' "$i"

   # From vdisk config printer get vdisk ids for the vmdisks
   cmd="vdisk_config_printer --skip_shell_vdisks --nfs_file_name ${i}"
   vmDiskID=$(eval $cmd | grep "^vdisk_id" | awk '{print $2}')
   printf 'vdisk id is %s\n' "$vmDiskID"

   # Look through snapshot tree printer to check if the disks are part of a snapshot chain
   snapDisk=`snapshot_tree_printer | grep "$vmDiskID"`
   printf 'Printing snapshot chain for %s\n' "$vmDiskID"
   echo $snapDisk
done
