#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:30 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','./clouds')

module Clouds
  require 'version'
  require 'misc/logging'
  require 'misc/utils'
  require 'errors/exceptions'
  require 'config/settings'
  require 'plugins'
  require 'manager'

  def self.version
    Clouds::VERSION
  end

  def self.new(options)
    Clouds::Manager.new options
  end
end
