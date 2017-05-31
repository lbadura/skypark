require_relative '../test_helper'
require_relative '../../lib/parking_report'
require_relative '../../lib/parking_record'
require_relative '../../lib/license_record'
require_relative '../../lib/plate_reader'

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

    license_records = [
      LicenseRecord.new(Date.new(2017,5,1), "AAA123", nil, nil, 5.0),
      LicenseRecord.new(Date.new(2017,5,1), "BBB456", nil, nil, 5.0),
      LicenseRecord.new(Date.new(2017,5,1), "CCC789", nil, nil, 5.0),
    ]

    plate_reader = mock()
    plate_reader.stubs(:owner).at_least_once.with("AAA123").returns("John")
    plate_reader.expects(:owner).at_least_once.with("BBB456").returns(PlateReader::UNKNOWN)
    plate_reader.expects(:owner).at_least_once.with("CCC789").returns("Ian")
    plate_reader.expects(:owner).at_least_once.with("DDD000").returns("Ian")
    @report = ParkingReport.new(license_records, parking_records, plate_reader: plate_reader)
    @result = @report.call
  end

  def test_report
    john = @result.find {|r| r.owner == "John"}
    ian = @result.find {|r| r.owner == "Ian"}
    unknown = @result.find {|r| r.owner == PlateReader::UNKNOWN}
    assert_equal(john.usage.size, 4)
    # should sum total amount
    assert_equal(john.total, 26.15)
    # non matching owners aggregates as unknown
    assert_equal(6.74, unknown.total)
    # assigns multiple plates to the same owner
    assert_equal(8.15, ian.total)
  end

  def test_users
    assert(@report.users.include?(PlateReader::UNKNOWN))
    assert(@report.users.include?("John"))
    assert(@report.users.include?("Ian"))
    assert_equal(@report.users.size, 3)
  end

  def test_license_plates
    assert(@report.license_plates.include?("AAA123"))
    assert(@report.license_plates.include?("BBB456"))
    assert(@report.license_plates.include?("CCC789"))
    assert(@report.license_plates.include?("DDD000"))
    assert_equal(@report.license_plates.size, 4)
  end

  def test_unknown_license_plates
    assert(@report.unknown_license_plates.include?("BBB456"))
    assert_equal(1, @report.unknown_license_plates.size)
  end

  def test_total
    assert_equal(41.04, @report.total)
  end

  def test_csv
    csv_data = CSV.parse(@report.to_csv, headers: true)
    assert_equal("John", csv_data[0]["Name"])
    assert_equal("26.15", csv_data[0]["Amount"])
    assert_equal(PlateReader::UNKNOWN, csv_data[1]["Name"])
    assert_equal("6.74", csv_data[1]["Amount"])
    assert_equal("Ian", csv_data[2]["Name"])
    assert_equal("8.15", csv_data[2]["Amount"])
  end
end
