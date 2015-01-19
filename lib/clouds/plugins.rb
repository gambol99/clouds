#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:22 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
require 'fog'
require 'plugins/default'
require 'plugins/plugin'
require 'plugins/openstack'
require 'plugins/rackspace'

module Clouds
  module Plugins
    def plugins
      Clouds::Plugins.constants.select { |x|
        Class === Clouds::Plugins.const_get( x )
      }.delete_if { |x| x =~ /Plugin/ }
    end

    def plugin?(name)
      plugins.include? name.to_sym
    end

    private
    def load_plugin(name, configuration)
      debug "load_plugin: name: #{name}, configuration: #{configuration}"
      raise UnsupportedPlugin, "the plugin: #{name} is not supported" unless plugin? name
      Clouds::Plugins.const_get(name.to_sym).new(configuration.merge(options))
    end
  end
end
