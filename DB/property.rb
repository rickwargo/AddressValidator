require 'mysql2'

module DB

class Property
  attr_accessor :filter

  def records
    connect if @client.nil?

    @client.query(parcels_sql, symbolize_keys: true).each do |record|
      yield record
    end
  end

  def update(id, city, zipcode)
    @update_statement.execute(city, zipcode, id)
  end

  private

  def connect
    @client = Mysql2::Client.new(host: 'localhost', username: 'montco', password: 'slurpee', database: 'montco')
    @update_statement = @client.prepare(update_sql)
  end

  def parcels_sql
    %Q{
      SELECT parcel_id, left(parcel_id, 2) AS municipality, address, city, zipcode
      FROM properties
      WHERE (zipcode IS NULL
        AND parcel_id NOT LIKE '__0000000000'
        AND parcel_id LIKE '31__________')
        AND #{filter}
      }
  end

  def update_sql
    %q{
      UPDATE properties
      SET city = ?, zipcode = ?
      WHERE parcel_id = ?}
  end

end

end