require_relative 'core_engine'

module Engine

  class Homesnap < CoreEngine
    def find_city_zip_on(page)
      city = nil
      zip = page.at('//div[@class="address"]//span[@itemprop="postalCode"]/text()').to_s

      return city, zip
    end

    protected

    def initialize
      super

      @respawn_after_failure = true
      @time_wait = false
    end

    def gen_url(address, city)
      w = address.split
      if abbrev = Abbrev[w[-1]]
        w[-1] = abbrev
      end
      address = w.join('-')

      "http://www.homesnap.com/PA/#{city.gsub(/ /, '-')}/#{address.gsub(/ /, '-')}"
    end

  end
end
