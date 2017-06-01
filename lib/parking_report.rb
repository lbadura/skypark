require 'csv'
require_relative 'parking_report_row'

class ParkingReport
  def initialize(license_records, parking_records, options = {})
    @license_records = license_records
    @parking_records = parking_records
    @plate_reader = options[:plate_reader]
    @data = nil
  end

  def call
    data
  end

  def row(owner_name)
    data_row = @data.find {|d| d.owner == owner_name}
    unless data_row
      data_row = ParkingReportRow.new(owner_name)
      @data << data_row
    end
    data_row
  end

  def to_csv
    CSV.generate(col_sep: ",", row_sep: "\n") do |csv|
      csv << ["Name", "Amount"]
      @data.each do |row|
        csv << [row.owner, row.total]
      end
    end
  end

  def total
    @data.map {|r| r.total}.sum.round(2)
  end

  def owners
    @data.map {|r| r.owner}
  end

  def license_plates
    @data.map {|r| r.usage.map(&:license_plate)}.flatten.compact.uniq
  end

  def unknown_license_plates
    records = @data.select {|r| r.owner == PlateReader::UNKNOWN }.map(&:usage).flatten
    records.map(&:license_plate).uniq
  end

  def plate_reader
    @plate_reader ||= PlateReader.new
  end

  private
  def data
    return @data if @data
    @data = []
    @parking_records.each do |pr|
      owner_name = plate_reader.owner(pr.license_plate)
      row(owner_name).add_record(pr)
    end
    @license_records.each do |lr|
      owner_name = plate_reader.owner(lr.license_plate)
      row(owner_name).add_record(lr)
    end
    @data
  end
end
