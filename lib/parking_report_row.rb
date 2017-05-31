class ParkingReportRow
  def initialize(owner)
    @owner = owner
    @usage = []
  end

  def add_record(record)
    @usage << record
  end

  def total
    usage.map {|u| u.gross_fee}.sum.round(2)
  end

  attr_reader :owner, :usage
end
