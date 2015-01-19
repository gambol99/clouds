#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-08-29 13:05:09 +0100 (Fri, 29 Aug 2014)
#
#  vim:ts=4:sw=4:et
#
module Clouds
  module Cache
    @cache = {}
    def cache(key, ttl = 10)
      return @cache[key] if cached? key
      @cache[key] = yield
    end

    def cached?(key)
      @cache.has_key? key
    end
  end
end
