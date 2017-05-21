require_relative '../test_helper'
require_relative '../../lib/parking_report'
require_relative '../../lib/parking_record'

class ParkingReportTest < Minitest::Test
  def setup
    parking_records = [
      ParkingRecord.new("AAA123",nil,nil,12.10),
      ParkingRecord.new("AAA123",nil,nil,7.90),
      ParkingRecord.new("AAA123",nil,nil,0.0),
      ParkingRecord.new("BBB456",nil,nil,0.59),
      ParkingRecord.new("CCC789",nil,nil,1),
      ParkingRecord.new("DDD000",nil,nil,1),
    ]
    plate_reader = mock()
    plate_reader.expects(:owner).times(3).with("AAA123").returns("John")
    plate_reader.expects(:owner).with("BBB456").returns("Unknown")
    plate_reader.expects(:owner).with("CCC789").returns("Ian")
    plate_reader.expects(:owner).with("DDD000").returns("Ian")
    @result = ParkingReport.new(parking_records, plate_reader).call
  end

  def test_report
    # should aggregate all plate expenses
    assert_equal(@result["John"]["AAA123"], [ParkingReport::INITIAL_FEE, 12.10, 7.90, 0.0])
    # should sum total amount + initial fee
    assert_equal(@result["John"]["total"], ParkingReport::INITIAL_FEE + 12.10 + 7.90 +0.0)
    # non matching owners aggregates as unknown
    assert_equal(@result["Unknown"]["total"], ParkingReport::INITIAL_FEE + 0.59)
    # assigns multiple plates to the same owner
    assert_equal(@result["Ian"]["total"], (ParkingReport::INITIAL_FEE * 2) + 1 + 1)
    assert(@result["Ian"].include?("CCC789"))
    assert(@result["Ian"].include?("DDD000"))
  end
end
