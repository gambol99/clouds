#!/usr/bin/env ruby
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-29 11:16:50 +0100 (Fri, 29 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','../lib')
require 'clouds'
require 'colorize'
require 'pp'

def check(message)
  begin
    puts "\n[CHECK]".green << ": #{message}\n"
    start = Time.now
    yield
    time_taken = Time.now - start
    puts '[PASSED] Timing: %f.2ms'.green % [time_taken]
  rescue Exception => e
    puts "[FAILED] #{e.message}".red
  end
end

c = Clouds.new( {
  :config  => './config.yaml',
  :debug   => true,
  :verbose => false
} )

check 'pulling a list of the supported plugins / providers' do
  puts c.plugins
end

check 'display the clouds configuration' do
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

check 'pulling a list of all the networks' do
  c.clouds.each do |cloud|
    c.load_cloud( cloud ).networks.each do |network|
      puts "cloud: #{cloud}, network: #{network}"
    end
  end
end

check 'checking the networks exists' do
  c.clouds.each do |name|
    cloud = c.load_cloud( name )
    cloud.networks.sample(2).each do |x|
      puts "cloud: #{name}, network: #{x}, exists?: #{cloud.network?(x)}"
    end
  end
end

check 'pulling the images: ' do
  c.clouds.each do |cloud|
    c.load_cloud( cloud ).images.each do |x|
      puts "cloud: #{cloud}, image: #{x}"
    end
  end
end

check 'checking an instance exists' do
  c.clouds.each do |name|
    cloud = c.load_cloud( name )
    cloud.servers.sample(2).each do |x|
      puts "cloud: #{name}, server: #{x}, exists?: #{cloud.exists?(x)}"
    end
  end
end

check 'checking the flavors' do
  c.clouds.each do |cloud|
    c.load_cloud( cloud ).flavors.sample(2).each do |x|
      puts "cloud: #{cloud}, flavor: #{x}"
    end
  end
end

check 'checking the flavor? works' do
  c.clouds.each do |name |
    cloud = c.load_cloud( name )
    cloud.flavors.sample(2).each do |x|
      puts "cloud: #{name}, flavor: #{x}, flavor?: #{cloud.flavor?(x)}"
    end
  end
end
check 'pulling details on an instance' do
  c.clouds.each do |name |
    cloud = c.load_cloud( name )
    cloud.servers.sample(2).each do |x|
      puts "cloud: #{name}, server: #{x}, addresses: #{cloud.addresses(x)}"
    end
  end
end

#check "building a instance in the cloud" do
#  cloud = c.load_cloud( 'rpc' )
#  hostname = 'rohith101.domain.com'
#  server = cloud.launch( hostname,
#    {
#      :image  => 'CentOS 6.5',
#      :flavor => '512MB Standard Instance'
#    }
#  )
#  puts "server: #{hostname}, addresses: #{cloud.addresses(hostname)}"
#end

#check "destroy a server in the cloud" do
#  hq = c.load_cloud( 'rpc' )
#  hostname = 'rohith101.domain.com'
#  puts "deleting the server: #{hostname}"
#  server = hq.destroy( hostname )
#end
