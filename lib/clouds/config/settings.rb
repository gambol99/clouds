#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:42:24 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
require 'yaml'

module Clouds
  module Settings
    def validate_configuration
      # step: check we have a configuration file to load
      raise ArgumentError, 'you have not specified configuration file' unless options[:config]
      validate_file options[:config]
      # step: load the configuration file and validate we have the requirements
      config = ::YAML.load(File.read(options[:config]))
      # step: validate the clouds
      @settings = validate_cloud_configuration config
    end

    def clouds
      @settings['clouds'].keys
    end

    def cloud?(name)
      clouds.include? name
    end

    def cloud(name)
      settings['clouds'][name]
    end

    def options(options_settings = nil)
      @options ||= options_settings
    end

    private
    def validate_cloud_configuration(config)
      raise ArgumentError, 'you have not specified any cloud configuration in the config' unless config['clouds']
      raise ArgumentError, 'the cloud configuration should be a hash' unless config['clouds'].is_a? Hash
      # step: iterate the clouds and make sure we have a provider at the very least
      config['clouds'].each_pair do |name, cfg|
        raise ArgumentError, "cloud: #{name} - you have not specified a provider" unless cfg['provider']
      end
      config
    end

    def settings
      @settings ||= {}
    end
  end
end
