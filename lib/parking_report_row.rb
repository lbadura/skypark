class ParkingReportRow
  def initialize(owner, department)
    @owner = owner
    @department = department
    @usage = []
  end

  def add_record(record)
    @usage << record
  end

  def total
    usage.map {|u| u.gross_fee}.sum.round(2)
  end

  def license_costs
    usage.select {|u| u.class.to_s == "LicenseRecord"}.map(&:gross_fee).sum.round(2)
  end

  def parking_costs
    usage.select {|u| u.class.to_s == "ParkingRecord"}.map(&:gross_fee).sum.round(2)
  end

  attr_reader :owner, :usage, :department
end
