#
# Recipe:: default
#

package node['lvm_mount']['lvm_package'] do
  action :install
end

node['lvm_mount']['disks'].each do |_disk|
  _prefix = _disk['prefix']
  _pv_string = ''
  _best_filesystem = LVM_MOUNT.bestFilesystem(node['lvm_mount']['fs_formats'])
  _format = _disk['filesystem'] || _best_filesystem
  _pvs=(node['lvm_mount']['auto_find_pv']==true) ? 
    LVM_MOUNT.findDisks(node['lvm_mount']['auto_find_pv_prefixes'],node['lvm_mount']['auto_find_pv_limit']) : 
    _disk['pv'].dup
  _pvs.each do |_pv|
    _pvexists = LVM_MOUNT.pvExists(_pv)
    execute "Initialising PV: #{_pv}" do
      command "pvcreate -y #{_pv}"
      not_if _pvexists
    end
    _pv_string << "#{_pv} " unless _pvexists
  end
  execute "Creating VG: #{_prefix}vg" do
    command "vgcreate -y #{_prefix}vg #{_pv_string}"
    not_if LVM_MOUNT.vgExists(_prefix + 'vg')
  end
  execute "Creating LV: #{_prefix}lv" do
    command "lvcreate -L #{_disk['size']} -n #{_prefix}lv #{_prefix}vg"
    not_if LVM_MOUNT.lvExists(_prefix + 'lv')
  end
  execute "Formating: /dev/#{_prefix}vg/#{_prefix}lv as #{_format}" do
    command "mkfs -t #{_format} /dev/#{_prefix}vg/#{_prefix}lv"
    not_if LVM_MOUNT.isMounted("/dev/mapper/#{_prefix}vg-#{_prefix}lv") ||
             LVM_MOUNT.isMounted("/dev/#{_prefix}vg/#{_prefix}lv")
  end
  mount _mountpoint do
    device "/dev/#{_prefix}vg/#{_prefix}lv"
    fstype _format
    options _disk['mount_options'] || 'auto,defaults'
    action [:mount, :enable]
  end
end

