require 'mechanize'
require 'open-uri'
require 'uri'
require_relative '../cities'
require_relative '../abbrevs'

module Engine
  UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36'

  class CoreEngine
    def urls(municipality, address, city, last_city)
      # find the zip code of a specified city
      unless city.nil?
        url = gen_url(address, city)
        yield url, city
        return  # no more if a specific city is supplied
      end

      # search for a city and zip code based on the previously seen city (high likelihood the current city is the last city)
      unless last_city.nil?
        url = gen_url(address, last_city)
        yield url, last_city
      end

      # sequence through the known cities in the municipality looking for the city and zip code
      Cities[municipality.to_i].each do |city|
        url = gen_url(address, city)
        yield url, city
      end if city.nil? || city.empty?
    end

    def get_page_for(url)
      duration = 1 if @time_wait
      attempt = 0
      begin
        # Inc vars prior to getting page as retry in begin/rescue/end needs to increase counters
        attempt += 1
        @query_count += 1

        page = agent.get url
      rescue => err
        if err.response_code.to_i >= 500
          puts "Stopped by server."
          exit(1)
        end

        if @respawn_after_failure
          respawn unless @time_wait || attempt < @attempts
        end

        if @time_wait
          puts "Waiting #{duration} second(s)..."
          sleep duration
          duration = duration * 2
        end

        retry if err.response_code.to_i < 400
        page = nil
      end

      return page
    end

    def property_filter
      "1 = 1"
    end

    protected

    def initialize
      @query_count = 0
      @respawn_after_failure = true
      @time_wait = false
      @attempts = 4
      @delay_factor = 2
    end

    def gen_url(address, city)
      nil
    end

    def find_city_zip_on(address, city, page)
      nil
    end


    private

    def respawn
      @agent.reset
      @agent.shutdown
      @agent = nil
    end

    def agent
      return @agent unless @agent.nil?

      return @agent = Mechanize.new do |agent|
                        agent.user_agent = UA
                        agent.follow_meta_refresh = true
                      end
    end

  end

end
