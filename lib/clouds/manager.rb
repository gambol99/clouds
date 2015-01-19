#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:53:27 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  class Manager
    include Clouds::Settings
    include Clouds::Logging
    include Clouds::Utils
    include Clouds::Plugins

    def initialize(app_configuration)
      options app_configuration
      validate_configuration
    end

    def configuration(name)
      debug "loading the configuration for cloud: #{name}"
      raise ArgumentError, "the cloud configuration for: #{name} does not exist" unless cloud? name
      cloud name
    end

    def load_cloud(name)
      config = configuration name
      debug "load_cloud: loading a plugin instance: #{config['provider']} for cloud: #{name}"
      unless loaded? name
        loaded[name] = load_plugin config['provider'], config
        debug "load_cloud: succesfully loaded the cloud: #{name}"
      end
      loaded[name]
    end

    private
    def loaded
      @loaded ||= {}
    end

    def loaded?(name)
      loaded.has_key? name
    end
  end
end
