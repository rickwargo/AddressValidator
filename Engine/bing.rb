require_relative 'core_engine'

module Engine

  class Bing < CoreEngine
    def find_city_zip_on(address, city, page)
      zip = nil
      zip = find(page, '//h2[@class="b_topTitle"]', /#{city},\s+PA,?\s+(1[89]\d{3})/i) if zip.nil?
      zip = find(page, '//div[@class="b_subModule"]/ul[2]/li[1]/a', /#{city},\s+PA,?\s+(1[89]\d{3})/i) if zip.nil?
      new_city, zip = find(page, '//h2[@class="b_topTitle"]', /#{address}\.?,?\s+([a-z ]+),?\s+PA.{1,3}(1[89]\d{3})/i) if zip.nil?
      zip = find(page, '//li[@class="b_algo"]/h2/a', /#{address}\.?,?\s+#{city},?\s+PA,?\s+(1[89]\d{3})/i) if zip.nil?

      city = new_city if new_city
      return city, zip
    end

    protected

    def initialize
      super

      @respawn_after_failure = true
      @time_wait = false
    end

    def gen_url(address, city)
      "https://www.bing.com/search?q=#{address}+#{city}+PA"
    end

    private

    def find(page, xpath, expr)
      paths = page.at(xpath)
      #match = paths.map{ |a| a.to_s }.join unless paths.nil?
      path = paths.text unless paths.nil?
      if matches = expr.match(path)
        return matches.length > 2 ? matches[1..-1] : matches[1]
      else
        return nil
      end
    end

  end

end