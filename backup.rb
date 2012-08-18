#!/usr/bin/env ruby
require 'forwardable'
require 'logger'

class Main
  class << self
    extend Forwardable

    def_delegators :logger,
      :debug, :info, :warn, :error, :fatal

    def run!(argv)
      info "mounting backup drives"
      runner("/bin/mount /mnt/backup", true)
      runner("/bin/mount /mnt/backup-media", true)

      rsync  = '/usr/bin/rsync -a --delete --delete-excluded'
      rsync += ' --verbose' if argv.include?('--verbose')

      info "backing up system directories"
      runner("#{rsync} /etc /usr /var /boot /mnt/backup/")

      info "backing up home directory"
      runner("#{rsync} --exclude Documents/ripping /home/patrick /mnt/backup/home/")

      info "backing up media"
      runner("#{rsync} --exclude Downloads /mnt/media/* /mnt/backup-media/")

      info "backing up HTPC"
      runner("#{rsync} -e ssh root@htpc:/etc root@htpc:/home/xbmc /mnt/backup/htpc/")

    rescue => ex
      fatal "#{ex}"
      exit 1
    ensure
      info "unmounting backup drives"
      runner("/bin/umount /mnt/backup")
      runner("/bin/umount /mnt/backup-media")
    end

    private

    def runner(cmd, die_on_error = false)
      unless system(cmd)
        msg = "#{cmd} returned non-zero exit code: #{$?}"

        raise msg if die_on_error
        error msg
      end
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end

Main.run! ARGV
