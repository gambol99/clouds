#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:05 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Plugins
    class Plugin
      include Clouds::Logging
      include Clouds::Utils
      include Clouds::Errors
      include Clouds::Plugins::Default

      def initialize(configuration)
        config configuration
      end

      def unsupported
        raise UnsupportedMethod
      end

      def config(configuration = nil)
        @config ||= configuration
      end
      alias_method :options, :config
    end
  end
end

