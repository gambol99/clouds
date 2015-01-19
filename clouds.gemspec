#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-29 17:31:01 +0100 (Fri, 29 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','lib/clouds' )
require 'version'

Gem::Specification.new do |s|
  s.name        = 'cloud-builder'
  s.version     = Clouds::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-08-29'
  s.authors     = ['Rohith Jayawardene']
  s.email       = 'gambol99@gmail.com'
  s.homepage    = 'https://github.com/gambol99/clouds'
  s.summary     = %q{A little integration piece for building in openstack/rackspace}
  s.description = %q{A small library which was used to bootstrap our openstack and rackspace instances}
  s.license     = 'GPL'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency 'fog'
end
