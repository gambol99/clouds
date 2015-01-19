

Clouds
======

Was / is a small library used in our build process for bootstrapping boxes in openstack and rackspace. Checkout the ./tests for examples

    c = Clouds::new( {
      :config  => './config.yaml',
      :debug   => true,
      :verbose => false
    } )

    check "pulling a list of the supported plugins / providers" do
      puts c.plugins
    end

    check "display the clouds configuration" do
      c.clouds.each do |cloud|
        puts "cloud: #{cloud}, configuration => #{c.configuration( cloud )}"
      end
    end

    check 'pulling a list of servers from all the clouds' do
      c.clouds.each do |cloud|
        c.load_cloud( cloud ).servers.each do |instance|
          puts "cloud: #{cloud}, instance: #{instance}"
        end
      end
    end


Configurations
==============

    clouds:
      hq:
        provider: Openstack
        openstack_tenant: TENANT
        openstack_username: USERNAME
        openstack_api_key: PASSWORD
        openstack_auth_url: http://horizon.domain.com:5000/v2.0/tokens
      sbx:
        provider: Openstack
        openstack_tenant: TENANT
        openstack_username: USERNAME
        openstack_api_key: PASSWORD
        openstack_auth_url: http://horizon.domain.com:5000/v2.0/tokens
      rpc:
        provider: Rackspace
        rackspace_username: USERNAME
        rackspace_api_key: TOKEN
        rackspace_region: :lon
