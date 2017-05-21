require 'csv'
require_relative 'parking_record'

class ParkingReportParser
  def initialize(io, options = {})
    @io = io
    @col_sep = options[:col_sep] || ";"
    @headers = true
  end

  def call
    csv_data.map do |row|
      record = ParkingRecord.new
      record.plate = row[1]&.upcase
      record.start_time = DateTime.parse(row[4])
      record.end_time = DateTime.parse(row[5])
      record.amount = row[6].gsub(",",".").to_f
      record.total_time = row[7]
      record
    end
  end

  private
  def csv_data
    @csv_data ||= CSV.parse(@io, headers: @headers, col_sep: @col_sep)
  end
end
