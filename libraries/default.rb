class Chef::Recipe::LVM_MOUNT
  def initialise
    ENV['PATH'] = '/bin:/usr/bin:/sbin:/usr/sbin'
  end
  def isMounted(path)
    _mounts = IO.readlines('/proc/mounts')
    _mounts.each do |_m|
      _mountinfo = _m.split(' ')
      $stderr.puts _mountinfo.inspect
      return 1 if path==_mountinfo[0] 
      return 2 if path==_mountinfo[1] 
    end
    return nil
  end
  def bestFilesystem(acceptable)
    acceptable = [ 'xfs','ext4','ext3','ext2' ] unless acceptable.kind_of?(Array)
    accepted = 'ext2'
    _fs = IO.readlines('/proc/filesystems')
    _fs.each do |_f|
      _fsinfo = _f.split(' ')
      accepted = _fsinfo[1].to_s if acceptable.index(_fsinfo[1].to_s) < acceptable.index(accepted)
    end
    Chef::Log.info("Using filesystem: #{accepted}"
    return accepted
  end
  def pvExists(path)
    _pv = `pvdisplay -c`
    _pv.each_line {|_pv_line|
      _pv_line.gsub!(/\A\s+/,'')
      _pv_line.gsub!(/\s+\Z/,'')
      _pvinfo = _pv_line.split(':')
      $stderr.puts _pvinfo.inspect
      return 1 if path==_pvinfo[0]
      return 2 if path==_pvinfo[1]
    }
    return nil
  end
  def vgExists(path)
    _vg = `vgdisplay -c`
    _vg.each_line {|_vg_line|
      _vg_line.gsub!(/\A\s+/,'')
      _vg_line.gsub!(/\s+\Z/,'')
      _vginfo = _vg_line.split(':')
      $stderr.puts _vginfo.inspect
      return 1 if path==_vginfo[0]
    }
    return nil
  end
  def lvExists(path)
    _lv = `lvdisplay -c`
    _lv.each_line {|_lv_line|
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



