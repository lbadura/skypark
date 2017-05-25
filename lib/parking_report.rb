require 'csv'

class ParkingReport
  INITIAL_FEE = 6.15
  UNKNOWN = 'unknown'

  def initialize(parking_records, plate_reader)
    @parking_records = parking_records
    @plate_reader = plate_reader
    @data = nil
  end

  def call
    return @data if @data
    res = {}
    @parking_records.each do |pr|
      owner = @plate_reader.owner(pr.plate)
      owner_name = owner || UNKNOWN
      res[owner_name] = {"total" => 0.0} unless res[owner_name]
      unless res[owner_name][pr.plate]
        res[owner_name][pr.plate] = [INITIAL_FEE]
        res[owner_name]["total"] += INITIAL_FEE
      end
      res[owner_name][pr.plate] << pr.amount
      res[owner_name]["total"] += pr.amount
    end
    @data = res
  end

  def to_csv
    data = call
    CSV.generate(col_sep: ",", row_sep: "\n") do |csv|
      csv << ["Name", "Amount"]
      data.each do |record|
        csv << [record[0], record[1]["total"].round(2)]
      end
    end
  end

  def total
    @data.map {|_,v| v["total"]}.sum.round(2)
  end

  def users
    @data.map {|k,_| k}
  end

  def cars
    @data.map {|_, plate| plate.keys.reject {|k| k == "total"}}.flatten.uniq
  end

  def unknown_cars
    @data.select {|owner, _| owner == UNKNOWN }.map do |_, plate|
      plate.keys.reject {|k| k == "total"}
    end.flatten.uniq
  end
end
