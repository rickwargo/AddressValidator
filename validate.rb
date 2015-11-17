require_relative 'Engine/google'
require_relative 'DB/property'

class Validate
  def initialize
    @engine = Engine::Google.new
    @property = DB::Property.new
    @property.filter = @engine.property_filter
    @last_address = nil
    @last_city = nil
    @last_zip = nil
  end

  def validate_zips
    @property.records { |record| check_one record }
  end
  
  def check_one(record)
    if record[:address] == @last_address
      puts "[#{record[:parcel_id]}] municipality: #{record[:municipality]}; address: #{record[:address]}; city: #{@last_city} --> #{@last_zip} (from last)"
      @property.update(record[:parcel_id], @last_city, @last_zip)
    else
      @engine.urls(record[:municipality], record[:address], record[:city], @last_city) do |url, city|
        page = @engine.get_page_for url
        new_city, zip = @engine.find_city_zip_on(record[:address], city, page) unless page.nil?
        city = new_city unless new_city.nil?

        if zip.nil?
          puts "[#{record[:parcel_id]}] municipality: #{record[:municipality]}; address: #{record[:address]}; city: #{city} --> NOT FOUND"

          @last_address = nil
          @last_city = nil
          @last_zip = nil
        else
          puts "[#{record[:parcel_id]}] municipality: #{record[:municipality]}; address: #{record[:address]}; city: #{city} --> #{zip}"
          @property.update(record[:parcel_id], city, zip)

          @last_address = record[:address]
          @last_city = city
          @last_zip = zip

          break # found - no need to process any more
        end
      end
    end
  end
  
end

Validate.new.validate_zips