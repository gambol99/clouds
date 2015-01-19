#
#   Author: Rohith
#   Date: 2015-01-19 21:58:57 +0000 (Mon, 19 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
module Clouds
  module Plugins
    class Rackspace < Plugin
      def launch(hostname, attrs = {})
        debug "launch: attemping to launch: #{hostname}, attrs: #{attrs}"
        # step: checking we have the attributes
        required [:image, :flavor], attrs



      end

      private
      def ec2
        @ec2 ||= ::Fog::Compute.new( :provider => :AWS,
          :aws_access_key_id     => config['aws_access_key_id'],
          :aws_secret_access_key => config['aws_secret_access_key'],
          :region                => config['region'],
        )
      end
      alias_method :compute, :ec2
      alias_method :networking, :ec2
    end
  end
end

