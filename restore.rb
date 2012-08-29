#!/usr/bin/env ruby

system('/bin/mount -v /mnt/backup') or raise

ARGV.each do |f|
  file = File.expand_path(f)

  system("cp -v '/mnt/backup/#{file}' '#{file}'")
end

system('/bin/umount -v /mnt/backup')
