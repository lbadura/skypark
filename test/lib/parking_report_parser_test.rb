require_relative '../test_helper'
require_relative '../../lib/parking_report_parser'

class ParkingReportParserTest < Minitest::Test
  def setup
    io = File.read("test/fixtures/parking.csv")
    @parser = ParkingReportParser.new(io)
  end

  def test_data_size
    assert_equal(@parser.call.size, 2)
  end

  def test_upcased_plates
    assert_equal(@parser.call.first.license_plate, "KR116RC")
  end

  def test_float_amounts
    assert_equal(@parser.call.first.amount, 18.18)
  end
end
