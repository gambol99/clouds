#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:49:25 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
require 'timeout'

module Clouds
  module Plugins
    module Default
      def unsupported
        raise UnsupportedMethod
      end

      # ========================================================================
      # Compute / Hypervisors
      # ========================================================================
      alias_method :hypervisor, :unsupported
      alias_method :hypervisors, :unsupported
      alias_method :hypervisor?, :unsupported

      # ========================================================================
      # Instances
      # ========================================================================
      def waitfor(name, timeout = 180, interval = 0.2)
        begin
          Timeout::timeout timeout do
            loop do
              break if active? name
              debug "waitfor: hostname: #{name} not yet ready, going to sleep for #{interval}"
              sleep interval
            end
          end
          server name
        rescue Timeout::Error => e
          error "waitfor: we have timed out after #{timeout} seconds waiting for server: #{name}, error: #{e.message}"
          raise
        end
      end

      def active?(name)
        raise ArgumentError, "the server: #{name} does not exists" unless exists? name
        server(name).ready?
      end

      [ :delete, :reboot, :pause, :resume, :suspend, :unpause, :rebuild ].each do |m|
        define_method m do |hostname|
          failed "the server: #{hostname} does not exits" unless exists? hostname
          compute.send "#{m}_server", server( hostname ).id
        end
      end
      alias_method :destroy, :delete

      def addresses(name, timeout = 120, interval = 0.2, ip4 = true)
        list = []
        host = waitfor name, timeout, interval
        # step: we need to parse the structure
        host.addresses.each_pair do |x, addrs|
          addrs.each do |net|
            if ip4
              list << net['addr'] if ipv4? net['addr']
            else
              list << net['addr']
            end
          end
        end
        list
      end

      def instances
        compute.servers
      end

      [ :network, :server, :image, :flavor, :security_group, :key_pair ].each do |x|
        provider = ( x == :network ) ? :networking : :compute
        define_method x do |name|
          send( provider ).send( "#{x}s" ).select { |x|
            x if x.name == name or x.id == name
          }.first
        end
        define_method( "#{x}s") do
          list_name send( provider ).send "#{x}s"
        end
        define_method "#{x}?" do |name|
          ! send("#{x}", name ).nil?
        end
      end

      alias_method :keypair, :key_pair
      alias_method :keypair?, :key_pair?
      alias_method :keypairs, :key_pairs
      alias_method :exists?, :server?

      # ========================================================================
      # Images
      # ========================================================================
      def delete_image(name)
        compute.delete_image image(name).id
      end

      protected
      def list_name(list = [])
        list.map { |x| x.name }
      end
    end
  end
end

