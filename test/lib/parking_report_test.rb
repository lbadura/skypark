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
    plate_reader.expects(:owner).with("BBB456").returns(ParkingReport::UNKNOWN)
    plate_reader.expects(:owner).with("CCC789").returns("Ian")
    plate_reader.expects(:owner).with("DDD000").returns("Ian")
    @report = ParkingReport.new(parking_records, plate_reader)
    @result = @report.call
  end

  def test_report
    # should aggregate all plate expenses
    assert_equal(@result["John"]["AAA123"], [ParkingReport::INITIAL_FEE, 12.10, 7.90, 0.0])
    # should sum total amount + initial fee
    assert_equal(@result["John"]["total"], (ParkingReport::INITIAL_FEE + 12.10 + 7.90 + 0.0))
    # non matching owners aggregates as unknown
    assert_equal(@result[ParkingReport::UNKNOWN]["total"], ParkingReport::INITIAL_FEE + 0.59)
    # assigns multiple plates to the same owner
    assert_equal(@result["Ian"]["total"], (ParkingReport::INITIAL_FEE * 2) + 1 + 1)
    assert(@result["Ian"].include?("CCC789"))
    assert(@result["Ian"].include?("DDD000"))
  end

  def test_users
    assert(@report.users.include?(ParkingReport::UNKNOWN))
    assert(@report.users.include?("John"))
    assert(@report.users.include?("Ian"))
    assert_equal(@report.users.size, 3)
  end

  def test_cars
    assert(@report.cars.include?("AAA123"))
    assert(@report.cars.include?("BBB456"))
    assert(@report.cars.include?("CCC789"))
    assert(@report.cars.include?("DDD000"))
    assert_equal(@report.cars.size, 4)
  end

  def test_unknown_cars
    assert(@report.unknown_cars.include?("BBB456"))
    assert_equal(@report.unknown_cars.size, 1)
  end

  def test_total
    assert_equal(@report.total, 42.59)
  end
end
