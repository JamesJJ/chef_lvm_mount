#
# Recipe:: default
#

# install during the compilation phase!
package node['lvm_mount']['lvm_package'] do
  action :nothing
end.run_action(:install)

node['lvm_mount']['disks'].each do |_disk|
  _prefix = _disk['prefix']
  _mountpoint = _disk['mountpoint']
  _pv_string = ''
  _best_filesystem = LVM_MOUNT.bestFilesystem(node['lvm_mount']['fs_formats'])
  _format = _disk['filesystem'] || _best_filesystem
  _pvs=(node['lvm_mount']['auto_find_pv']==true) ? 
    LVM_MOUNT.findDisks(node['lvm_mount']['auto_find_pv_prefixes'],node['lvm_mount']['auto_find_pv_limit']) : 
    _disk['pv'].dup
  
  begin
    Chef::Log.fatal('No disks available to use')
    return
  end if _pvs.nil?

  begin
    Chef::Log.fatal("VG #{_prefix}vg already exists")
    return
  end if LVM_MOUNT.vgExists(_prefix + 'vg')
  begin
    Chef::Log.fatal("LV #{_prefix}lv already exists")
    return
  end if LVM_MOUNT.lvExists(_prefix + 'lv')
  begin
    Chef::Log.fatal("LVM already mounted /dev/mapper/#{_prefix}vg-#{_prefix}lv")
    return
  end if LVM_MOUNT.isMounted("/dev/mapper/#{_prefix}vg-#{_prefix}lv") || LVM_MOUNT.isMounted("/dev/#{_prefix}vg/#{_prefix}lv")

  _pvs.each do |_pv|
    begin
      Chef::Log.fatal("PV #{_pv} already exists")
      return
    end if LVM_MOUNT.pvExists(_pv)
    execute "Initialising PV: #{_pv}" do
      command "pvcreate -y #{_pv}"
    end
    _pv_string << "#{_pv} "
  end

  execute "Creating VG: #{_prefix}vg" do
    command "vgcreate -y #{_prefix}vg #{_pv_string}"
  end

  execute "Creating LV: #{_prefix}lv" do
    command "lvcreate -L #{_disk['size']} -n #{_prefix}lv #{_prefix}vg"
  end

  execute "Formatting: /dev/#{_prefix}vg/#{_prefix}lv as #{_format}" do
    command "mkfs -t #{_format} /dev/#{_prefix}vg/#{_prefix}lv"
  end

  mount _mountpoint do
    device "/dev/mapper/#{_prefix}vg-#{_prefix}lv"
    fstype _format
    options _disk['mount_options'] || 'auto,defaults'
    action [:mount, :enable]
  end
end

