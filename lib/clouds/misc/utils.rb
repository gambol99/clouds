#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:42 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Utils
    def validate_file(filename, writeable = false)
      raise ArgumentError, 'you have not specified a file to check' unless filename
      raise ArgumentError, 'the file %s does not exist' % [filename] unless File.exists? filename
      raise ArgumentError, 'the file %s is not a file' % [filename] unless File.file? filename
      raise ArgumentError, 'the file %s is not readable' % [filename] unless File.readable? filename
      if writeable
        raise ArgumentError, "the filename #{filename} is not writeable" unless File.writable? filename
      end
      filename
    end

    def validate_integer(value, min, max, name = 'value')
      int_value = value if value.is_a? Integer
      if value.is_a? String
        raise ArgumentError, "#{name} must be numeric" unless value =~ /^[[:digit:]]+$/
        int_value = value.to_i
      else
        raise ArgumentError, "the #{name} must be a integer or a string"
      end
      raise ArgumentError, "the #{name} cannot be less than #{min}" if int_value < min
      raise ArgumentError, "the #{name} cannot be greater than #{min}" if int_value > max
      int_value
    end

    def failed(message = '', argument = '')
      raise ArgumentError, message << " : invalid argument #{argument}"
    end

    def required(arguments, options)
      arguments.each do |x|
        raise ArgumentError, "you have not specified the #{x} options" unless options.has_key? x
      end
    end

    def ipv4?(address)
      address =~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/
    end
  end
end
