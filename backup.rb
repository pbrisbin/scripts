#!/usr/bin/env ruby
#
# pbrisbin 2012
#
###
class Main
  RSYNC = '/usr/bin/rsync -v -a --delete --delete-excluded'

  class << self
    def run!
      ex '/bin/mount -v /mnt/backup', true
      ex '/bin/mount -v /mnt/backup-media', true
      ex "#{RSYNC} /etc /usr /var /boot /mnt/backup/"
      ex "#{RSYNC} --exclude Documents/ripping /home/patrick /mnt/backup/home/"
      ex "#{RSYNC} --exclude Downloads /mnt/media/* /mnt/backup-media/"
      ex "#{RSYNC} -e ssh root@htpc:/etc root@htpc:/home/xbmc /mnt/backup/htpc/"

    rescue => e
      $stderr.puts "#{e}"
      exit 1

    ensure
      ex '/bin/umount -v /mnt/backup'
      ex '/bin/umount -v /mnt/backup-media'
    end

    private

    def ex(cmd, die_on_error = false)
      if !system(cmd) && die_on_error
        raise "#{cmd}: non-zero exit (#{$?})"
      end
    end
  end
end

Main.run!
