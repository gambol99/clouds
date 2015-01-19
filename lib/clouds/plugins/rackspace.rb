#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:14 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Plugins
    class Rackspace < Plugin
      def launch(hostname, attrs = {})
        debug "launch: attemping to launch: #{hostname}, attrs: #{attrs}"
        # step: checking we have the attributes
        required [:image, :flavor], attrs
        # step: set some default options
        attrs[:security_group] = [] unless attrs[:security_group]
        # step: validating the attributes
        failed 'image does not exist', attrs[:image] unless image? attrs[:image]
        failed 'flavor does not exist', attrs[:flavor] unless flavor? attrs[:flavor]
        #attrs[:security_group].each { |x| failed "security_group: #{x} does not exist" unless security_group? x }
        # step: creating the compute options for rackspace
        compute_options = {
            :name => hostname,
            :image_id => image(attrs[:image]).id,
            :flavor_id => flavor(attrs[:flavor]).id
        }
        # step: add a admin password if required
        compute_options[:adminPass] = attrs[:adminPass] if attrs[:adminPass]
        # step: add the networks
        (attrs[:networks] || []).each do |x|
          failed "the network: #{x} does not exist" unless network? x
          compute_options[:networks] << {:uuid => network(x).id}
        end
        # step: copy in the rest of the attributes
        [:key_name].each do |x|
          compute_options[x] = attrs[x] if attrs.has_key? x
        end
        compute_options[:config_drive] = true if attrs[:user_data]
        compute_options[:user_data] = attrs[:user_data] if attrs[:user_data]
        # step: launch the instance
        compute.servers.create compute_options
        debug "launch: successfully launched the instance: #{hostname}"
        waitfor hostname if block_given?
      end

      # ===== Overrides from the default - as rackspace defer label vs name (why oh why)
      def network(name)
        networking.networks.select { |x|
          x.label == name or x.id == name
        }.first
      end

      def networks
        rackspace.networks.map { |x| x.label }
      end

      # rackspace does not support security groups
      alias_method :security_group, :unsupported
      alias_method :security_groups, :unsupported
      alias_method :security_group?, :unsupported

      private
      def rackspace
        @rackspace ||= ::Fog::Compute.new( :provider => :Rackspace,
          :rackspace_username => config['rackspace_username'],
          :rackspace_api_key  => config['rackspace_api_key'],
          :rackspace_region   => config['rackspace_region'].to_sym,
        )
      end
      alias_method :compute, :rackspace
      alias_method :networking, :rackspace
    end
  end
end

