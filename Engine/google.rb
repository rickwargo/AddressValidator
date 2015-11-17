require_relative 'core_engine'

module Engine

  class Google < CoreEngine
    def find_city_zip_on(address, city, page)
      city = nil
      zip = nil
      zip = $1 if zip.nil? && page.at('//div[@class="vk_sh vk_bk"]/text()').to_s =~ /#{city},\s+PA\s+(1[89]\d{3})/i
      city, zip = $1, $2 if zip.nil? && page.at('//div[@class="vk_sh vk_bk"]/text()').to_s =~ /#{address}\.?,?\s+([a-z ]+),?\s+PA.{1,3}(1[89]\d{3})/i
      zip = $1 if zip.nil? && page.search('//div[@class="rc"]/h3/a').map{ |a| a.text }.join =~ /#{city},\s+PA\s+(1[89]\d{3})/i
      if zip.nil?
        abbrev = address.split[-1].upcase
        long = Abbrev[abbrev]
        address = address.split[0..-2].join(' ') + '\s+(' + abbrev + (long.nil? ? '' : '|' + long) + ')'
        city, zip = $2, $3 if zip.nil? && page.search('//div[@class="rc"]/h3/a').map{ |a| a.text }.join =~ /#{address},?\s+([a-z ]+)\.?,?\s+PA.{1,3}(1[89]\d{3})/i
      end

      return city, zip
    end

    protected

    def initialize
      super

      @respawn_after_failure = true
      @time_wait = false
    end

    def gen_url(address, city)
      "https://www.google.com/search?q=#{address}+#{city}+PA"
    end
  end

end