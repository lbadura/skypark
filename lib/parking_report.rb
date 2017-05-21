class ParkingReport
  INITIAL_FEE = 5.0
  UNKNOWN = 'unknown'

  def initialize(parking_records, plate_reader)
    @parking_records = parking_records
    @plate_reader = plate_reader
  end

  def call
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
    res
  end
end
