require 'pdf-reader'

class LicenseReportParser
  PLATE_REGEXP = /\s([a-zA-Z]{2,5}\d{1,5}[a-zA-Z\d]{0,5})\s/i

  def initialize(io)
    @io = io
    @matcher = Regexp.new(PLATE_REGEXP)
  end

  def call
    records
  end

  def license_plates
    records.map {|r| r.license_plate}
  end

  private
  def records
    @records ||= lines.map do |line|
      record = line.split(" ")
      period_date = Date.parse(record[0])
      license_plate = record[1].upcase
      added_on = Date.parse(record[2])
      if record[3] =~ /,/
        removed_on = nil
        fee = record[3].gsub(",",".").to_f
      else
        removed_on = Date.parse(record[3])
        fee = record[4].gsub(",",".").to_f
      end
      LicenseRecord.new(period_date, license_plate, added_on, removed_on, fee)
    end
  end

  def lines
    @lines ||= reader.pages.map do |page|
      page.text.split("\n").select {|line| @matcher.match(line) }
    end.flatten.compact
  end

  def reader
    @reader ||= PDF::Reader.new(@io)
  end
end
