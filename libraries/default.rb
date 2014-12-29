module Chef::Recipe::LVM_MOUNT
  include Chef::Mixin::ShellOut
  def initialise
    ENV['PATH'] = '/bin:/usr/bin:/sbin:/usr/sbin'
  end
  def self.findDisks(prefixes,limit)
    _regex = Regexp.new("\A(" + prefixes.join('|') + ")")
    _disks=Array.new()
    _p = IO.readlines('/proc/partitions')
    _p.each do |_d|
      _pdev = _d.split(' ')[3]
      _disks.push(_pdev) if _regex.match(_pdev)
    end
    _found = _disks.sort.reverse.take(limit||1).collect {|_d| "/dev/" + _d }
    Chef::Log.info("Using disks: " + _found.join(' '))
  end
  def self.isMounted(path)
    _mounts = IO.readlines('/proc/mounts')
    _mounts.each do |_m|
      _mountinfo = _m.split(' ')
      $stderr.puts _mountinfo.inspect
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
      accepted = _fsinfo[1].to_s if 
        (!acceptable.index(_fsinfo[1].to_s).nil?) && 
        (acceptable.index(_fsinfo[1].to_s).to_i < acceptable.index(accepted).to_i)
    end
    Chef::Log.info("Using filesystem: #{accepted}")
    return accepted
  end
  def self.pvExists(path)
    _pv = shell_out!('pvdisplay -c')
    _pv.stdout.each_line {|_pv_line|
      _pv_line.gsub!(/\A\s+/,'')
      _pv_line.gsub!(/\s+\Z/,'')
      _pvinfo = _pv_line.split(':')
      $stderr.puts _pvinfo.inspect
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
      _vginfo = _vg_line.split(':')
      $stderr.puts _vginfo.inspect
      return 1 if path==_vginfo[0]
    }
    return nil
  end
  def self.lvExists(path)
    _lv = shell_out!('lvdisplay -c')
    _lv.stdout.each_line {|_lv_line|
      _lv_line.gsub!(/\A\s+/,'')
      _lv_line.gsub!(/\s+\Z/,'')
      _pvinfo = _lv_line.split(':')
      $stderr.puts _lvinfo.inspect
      return 1 if path==_lvinfo[0]
      return 2 if path==_lvinfo[1]
    }
    return nil
  end
end



