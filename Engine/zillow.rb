require_relative 'core_engine'

module Engine

  class Zillow < CoreEngine
    def find_city_zip_on(page)
      city = nil
      zip = begin $1 if page.at('//span[@class="zsg-h2 addr_city"]').text.strip =~ /.*\s+(1[89]\d{3})\Z/ rescue nil end

      return city, zip
    end

    def property_filter
      "land_use_description like 'R - %' AND address rlike '^[1-9]'"
    end

    protected

    def initialize
      super

      @respawn_after_failure = true
      @time_wait = false
    end

    def gen_url(address, city)
      "http://www.zillow.com/homes/#{address.gsub(/ /, '-')}-#{city.gsub(/ /, '-')}-PA_rb"
    end

  end
end
