default['lvm_mount']['lvm_package'] = 'lvm2'
default['lvm_mount']['fs_formats'] = ['xfs','ext4','ext3','ext2']
default['lvm_mount']['auto_find_pv'] = false
default['lvm_mount']['auto_find_pv_prefixes'] = ['xvd']
default['lvm_mount']['auto_find_pv_limit'] = 1
default['lvm_mount']['disks'] = nil

=begin

default['lvm_mount']['disks'] = [
  {
  prefix: "my-lvm-",
  filesystem: nil,
  pv: [ '/dev/sdp','/dev/sdq' ],
  size: "99.99G",
  mountpoint: "/opt",
  mount_options: "auto,defaults"
  }
]

=end
