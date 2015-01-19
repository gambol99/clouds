#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:10 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Plugins
    class Openstack < Clouds::Plugins::Plugin
      def launch(hostname, attrs = {})
        debug "launch: attemping to launch: #{hostname}, attrs: #{attrs}"
        # step: check we have the min requirements
        required [:image, :flavor, :networks, :keypair, :security_group], attrs

        # step: check everything exists
        failed 'image does not exist', attrs[:image] unless image? attrs[:image]
        failed 'flavor does not exist', attrs[:flavor] unless flavor? attrs[:flavor]
        attrs[:networks].each { |x| failed "network: #{x} does not exist" unless network? x }
        attrs[:security_group].each { |x| failed "network: #{x} does not exist" unless security_group? x }

        # step: match up against the openstack attributes
        compute_options = {
            :name => hostname,
            :image_ref => image(attrs[:image]).id,
            :flavor_ref => flavor(attrs[:flavor]).id,
            :key_name => attrs[:keypair],
            :nics => []
        }
        # step: add the security groups
        compute_options[:security_groups] = attrs[:security_group] unless attrs[:security_group].empty?
        # step: set the availability_zone if defined
        compute_options[:availability_zone] = 'nova:%s' % [attrs[:availability_zone]] if attrs[:availability_zone]
        # step: add the user data if required
        compute_options[:user_data] = attrs[:user_data] if attrs[:user_data]
        # step: lets add the networks
        attrs[:networks].each { |net| compute_options[:nics] << {'net_id' => network(net).id} }
        # step: lets go ahead an create the instance
        compute.servers.create compute_options
        # step: wait for the instance to become available if requested
        waitfor hostname if block_given?
      end

      # ========================================================================
      # Compute / Hypervisors
      # ========================================================================
      def hypervisor(name)
        raise ArgumentError, 'the hypervisor host: %s does not exist' % [name] unless hypervisor? name
        compute.get_host_details(name).body
      end

      def hypervisors
        compute.list_hosts.body['hosts'].inject([]) do |a,host|
          a << host['host_name'] if host['service'] == 'compute'
          a
        end
      end

      def hypervisor?(name)
        hypervisors.include? name
      end

      # ========================================================================
      # Snapshots
      # ========================================================================
      def snapshot(name, snapshot, force = false)
        instance = server name
        if !force and image? snapshot
          raise ArgumentError, "the snapshot / image name: #{snapshot} already exists"
        end
        delete_image snapshot if image? snapshot
        compute.create_image instance.id, snapshot unless block_given?
      end

      private
      def stack; @stack ||= connection; end
      def compute; stack[:compute]; end
      def networking; stack[:network]; end
      def connection
        contain     = {}
        credentials = {
          :provider             => :OpenStack,
          :openstack_auth_url   => config['openstack_auth_url'],
          :openstack_api_key    => config['openstack_api_key'],
          :openstack_username   => config['openstack_username'],
          :openstack_tenant     => config['openstack_tenant']
        }
        contain[:compute] ||= ::Fog::Compute.new( credentials )
        contain[:network] ||= ::Fog::Network.new( credentials )
        contain
      end

      # ========================================================================
      # Floating ips
      # ========================================================================
      def float(address)
        raise ArgumentError, "the ipaddress: #{address} is not a valid ipaddress" unless ipv4? address
        raise ArgumentError, "the ipaddress: #{address} does not exist" unless float? address
        networking.list_floating_ips.body['floatingips'].select { |float| float if float['floating_ip_address'] == address }.first
      end

      def floats
        networking.list_floating_ips.body['floatingips'].map { |float| float['floating_ip_address'] }
      end

      def floating(hostname)
        raise ArgumentError, "the instance: #{hostname} does not exist" unless exists? hostname
        server(hostname).addresses['private_net'].select { |address|
          address if address['OS-EXT-IPS:type'] == 'floating'
        }.map { |address| address['addr'] }
      end

      def floats_free
        networking.list_floating_ips.body['floatingips'].select { |float|
          float if float['port_id'].nil?
        }.map { |float| float['floating_ip_address'] }.sort
      end

      def associate(hostname, floating_ip = nil, ip_address = nil)
        raise ArgumentError, "the instance: #{hostname} does not exist" unless exists? hostname
        if floating_ip.nil?
          # step: no floating ip assigned - lets assign the first free one
          floating_ip = self.floats_free.first
          raise ArgumentError, 'there are no free floating ip addresses left' unless floating_ip
        else
          # step: check the floating ip address is free
          raise ArgumentError, "the floating ip address: #{floating_ip} is not free" unless free? floating_ip
        end
        # step: we need to get our port
        instance_ports = ports hostname
        raise ArgumentError, "the hostname: #{hostname} does not have any network ports" unless !instance_ports.empty?
        if instance_ports.size > 1 and ip_address.nil?
          raise ArgumentError, "the hsot: #{hostname} has multiple port, we need to know which port your assigning"
        end
        instance_float_id = float(floating_ip).id
        instance_port_id = instance_ports.first
        result = networking.associate_floating_ip instance_float_id, instance_port_id
        result.body['floatingip']['floating_ip_address']
      end

      def deassociate(hostname)
        raise ArgumentError, "the instance: #{hostname} does not exist" unless exists? hostname
        raise ArgumentError, "the instance: #{hostname} is not floating" unless floating? hostname
        floating(hostname).each do |address|
          raise ArgumentError, "the floating_ip: #{address} doesnt appear to exist" unless float? address
          networking.disassociate_floating_ip(float(address).id)
        end
      end

      def free?(ipaddress)
        floats_free.include? ipaddress
      end

      def floating?(hostname)
        raise ArgumentError, "the instance: #{hostname} does not exist" unless exists? hostname
        !floating(hostname).empty?
      end

      def float?(address)
        !networking.list_floating_ips.body['floatingips'].select { |float|
          float if float['floating_ip_address'] =~ /^#{address}$/
        }.empty?
      end

    end
  end
end
