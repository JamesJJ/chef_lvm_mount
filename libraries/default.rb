require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

module Chef::Recipe::LVM_MOUNT
  def initialise
    ENV['PATH'] = '/bin:/usr/bin:/sbin:/usr/sbin'
  end
  def self.findDisks(prefixes,limit)
    _regex = Regexp.new('\A(' + prefixes.join('|') + ')')
    Chef::Log.debug("Using disk regex: " + _regex.inspect)
    _disks=Array.new()
    _p = IO.readlines('/proc/partitions')
    _p.each do |_d|
      _pdev = _d.split(' ')[3]
      next if _pdev.nil?
      Chef::Log.debug("Found disk: " + _pdev)
      _disks.push(_pdev) if _regex.match(_pdev)
    end
    _found = _disks.sort.reverse.take(limit||1).collect {|_d| "/dev/" + _d }
    Chef::Log.info("Using disks: " + _found.join(' '))
    return _found
  end
  def self.isMounted(path)
    _mounts = IO.readlines('/proc/mounts')
    _mounts.each do |_m|
      Chef::Log.debug("Found mount: " + _m)
      _mountinfo = _m.split(' ')
      return 1 if path==_mountinfo[0] 
      return 2 if path==_mountinfo[1] 
    end
    return nil
  end
  def self.bestFilesystem(acceptable)
    acceptable = [ 'xfs','ext4','ext3','ext2' ] unless acceptable.kind_of?(Array)
    accepted = 'ext2'
    _fs = IO.readlines('/proc/filesystems')
    _fs.each do |_f|
      _fsinfo = _f.split(' ')
      next if _f[0]=='nodev'
      Chef::Log.debug("Found filesystem: " + _f[1])
      accepted = _fsinfo[1].to_s if 
        (!acceptable.index(_fsinfo[1].to_s).nil?) && 
        (acceptable.index(_fsinfo[1].to_s).to_i < acceptable.index(accepted).to_i)
    end
    Chef::Log.info("Using filesystem: #{accepted}")
    return accepted
  end
  def self.pvExists(path)
    _pv = shell_out('pvdisplay -c')
    _pv.stdout.each_line {|_pv_line|
      _pv_line.gsub!(/\A\s+/,'')
      _pv_line.gsub!(/\s+\Z/,'')
      Chef::Log.debug("Found PV: " + _pv_line)
      _pvinfo = _pv_line.split(':')
      return 1 if path==_pvinfo[0]
      return 2 if path==_pvinfo[1]
    }
    return nil
  end
  def self.vgExists(path)
    _vg = shell_out!('vgdisplay -c')
    _vg.stdout.each_line {|_vg_line|
      _vg_line.gsub!(/\A\s+/,'')
      _vg_line.gsub!(/\s+\Z/,'')
      Chef::Log.debug("Found VG: " + _vg_line)
      _vginfo = _vg_line.split(':')
      return 1 if path==_vginfo[0]
    }
    return nil
  end
  def self.lvExists(path)
    _lv = shell_out!('lvdisplay -c')
    _lv.stdout.each_line {|_lv_line|
      _lv_line.gsub!(/\A\s+/,'')
      _lv_line.gsub!(/\s+\Z/,'')
      Chef::Log.debug("Found LV: " + _lv_line)
      _pvinfo = _lv_line.split(':')
      return 1 if path==_lvinfo[0]
      return 2 if path==_lvinfo[1]
    }
    return nil
  end
end



