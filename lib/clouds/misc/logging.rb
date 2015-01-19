#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-22 15:37:33 +0100 (Fri, 22 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Logging
    def info(string)
      print formatted_string("[info] #{dated_string(string)}", options) if options[:verbose]
    end

    def debug(string)
      print formatted_string("[debug] #{dated_string(string)}", options) if options[:debug]
    end

    def notify(string)
      print formatted_string(string, options)
    end
    alias_method :verbose, :notify

    def announce(string)
      print formatted_string(string, {:color => :white}.merge(options))
    end
    alias_method :verbose, :announce

    def warn(string)
      Kernel.warn formatted_string(string, :symbol => '*', :color => :orange, :newline => false)
    end

    def error(string)
      Kernel.warn formatted_string(string, :symbol => '!', :color => :red, :newline => false)
    end

    def newline
      puts
    end

    private
    def dated_string(string)
      "[#{Time.now}] #{string}"
    end

    def formatted_string( string, options = {} )
      symbol = options[:symbol] || ''
      string = string.to_s
      string = string.colorize( options[:color] ) if options[:color]
      string << "\n" unless !options[:newline]
      "#{symbol}#{string}[#{self.class}]"
    end
  end
end
