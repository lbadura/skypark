require 'csv'
require_relative 'parking_report_row'

class ParkingReport
  def initialize(license_records, parking_records, options = {})
    @license_records = license_records || []
    @parking_records = parking_records || []
    @plate_reader = options[:plate_reader]
    @data = nil
  end

  def call
    data
  end

  def row(owner_name, department)
    data_row = @data.find {|d| d.owner == owner_name}
    unless data_row
      data_row = ParkingReportRow.new(owner_name,department)
      @data << data_row
    end
    data_row
  end

  def to_csv
    CSV.generate(quote_char: "'", col_sep: ",", row_sep: "\n", converters: :all) do |csv|
      csv << ["Name", "Departmnet", "Amount"]
      @data.each do |row|
        csv << [row.owner, row.department, row.total]
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

  def by_department
    groupped = data.group_by(&:department)
    groupped.map do |group_name, records|
      OpenStruct.new({
        :department_name => group_name,
        :license_costs => records.sum(&:license_costs),
        :parking_costs => records.sum(&:parking_costs),
        :total => records.sum(&:total)
      })
    end.sort {|a,b| a.department_name <=> b.department_name}
  end

  private
  def data
    return @data if @data
    @data = []
    @parking_records.each do |pr|
      plate = plate_reader.find_by_plate(pr.license_plate)
      row(plate.name, plate.department).add_record(pr)
    end
    @license_records.each do |lr|
      plate = plate_reader.find_by_plate(lr.license_plate)
      row(plate.name, plate.department).add_record(lr)
    end
    @data
  end
end
