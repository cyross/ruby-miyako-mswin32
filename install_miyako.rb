# Miyako2.0 install script
# 2009 Cyross Makoto

if RUBY_VERSION < '1.9.1'
  puts 'Sorry. Miyako needs Ruby 1.9.1 or above...'
  exit
end

begin
require 'sdl'
rescue
  puts 'Sorry. Miyako needs Ruby/SDL...'
  exit
end

if SDL::VERSION < '2.1'
  puts 'Sorry. Miyako needs Ruby/SDL 2.1.0 or above...'
  exit
end

require 'rbconfig'
require 'fileutils'
require 'optparse'

option = { :noop => false, :verbose => true }
not_force = true

ARGV.options do |opt|
  opt.on('--no-harm'){ option[:noop] = true }
  opt.on('--force'){ not_force = false }
  opt.on('--quiet'){ option[:verbose] = false }

  opt.parse!
end

baselibdir = Config::CONFIG["sitelibdir"]
sitelibdir = baselibdir + "/Miyako"
apidir = sitelibdir + "/API"
extdir = sitelibdir + "/EXT"

if FileTest.exist?(sitelibdir) && not_force
  puts "#{sitelibdir} is arleady exists."
  puts "Are you sure?(Y/else)"
  exit unless $stdin.gets.split(//)[0].upcase == 'Y'
end

FileUtils.remove_dir(sitelibdir, true)
FileUtils.mkpath(sitelibdir, option)
FileUtils.mkpath(apidir, option)
FileUtils.mkpath(extdir, option)

Dir.glob("lib/*.rb"){|fname| FileUtils.install(fname, baselibdir, option)}
Dir.glob("lib/Miyako/*.rb"){|fname| FileUtils.install(fname, sitelibdir, option)}
Dir.glob("lib/Miyako/*.so"){|fname| FileUtils.install(fname, sitelibdir, option)}
Dir.glob("lib/Miyako/API/*.rb"){|fname| FileUtils.install(fname, apidir, option)}
Dir.glob("lib/Miyako/EXT/*.rb"){|fname| FileUtils.install(fname, extdir, option)}
