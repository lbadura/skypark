require 'google_drive'

class PlateReader
  UNKNOWN = 'unknown'

  class Row < OpenStruct; end

  def initialize
    @session = GoogleDrive::Session.from_service_account_key(Skypark::GOOGLE_CREDENTIALS_FILE)
  end

  def call
    plates
  end

  def find_by_plate(plate)
    sanitized_plate = plate.gsub(" ", "").upcase
    plates.find {|p| p.plate == sanitized_plate} || unknown
  end

  def unknown
    Row.new(department: UNKNOWN, name: UNKNOWN)
  end

  private
  def plates
    return @plates if @plates
    plates = []
    (2..worksheet.num_rows).each do |row|
      (1..worksheet.num_cols).each do |col|
        name = worksheet[row,1]
        plate = worksheet[row,2].gsub(" ", "").upcase
        department = worksheet[row,4]
        next if plate&.empty?
        unless plates.find {|p| p.plate == plate}
          plates << Row.new(plate: plate, department: department, name: name)
        end
      end
    end
    @plates = plates unless plates.empty?
  end

  def worksheet
    @worksheet ||= @session.spreadsheet_by_key(Skypark::REGISTRY_FILE_KEY).worksheets.select {|w| w.title == "Licenses"}.first
  end
end
