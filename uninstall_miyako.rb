# Miyako2.0 uninstall script
# 2009 Cyross Makoto

if RUBY_VERSION < '1.9.1'
  puts 'Sorry. Miyako needs Ruby 1.9.1 or above...'
  exit
end

require 'rbconfig'
require 'fileutils'

puts "Are you sure?(Y/else)"
exit unless $stdin.gets.split(//)[0].upcase == 'Y'

baselibdir = Config::CONFIG["sitelibdir"]
sitelibdir = baselibdir + "/Miyako"

FileUtils.remove(baselibdir+"/miyako.rb")
FileUtils.remove(baselibdir+"/miyako_require_only.rb")
FileUtils.remove_dir(sitelibdir, true)

puts "uninstall completed."
