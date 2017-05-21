require 'google_drive'

class PlateReader
  def initialize
    @session = GoogleDrive::Session.from_service_account_key(Skypark::GOOGLE_CREDENTIALS_FILE)
  end

  def call
    plates
  end

  def owner(plate)
    sanitized_plate = plate.gsub(" ", "").upcase
    plates.find {|_, license_plates| license_plates.include?(sanitized_plate)}&.first
  end

  private
  def plates
    return @plates if @plates
    plates = {}
    (2..worksheet.num_rows).each do |row|
      (1..worksheet.num_cols).each do |col|
        name = worksheet[row,1]
        plate = worksheet[row,2].gsub(" ", "").upcase
        plates[name] = [] unless plates[name]
        next if plate&.empty?
        plates[name] << plate unless plates[name].include?(plate)
      end
    end
    @plates = plates unless plates.empty?
  end

  def worksheet
    @worksheet ||= @session.spreadsheet_by_key(Skypark::REGISTRY_FILE_KEY).worksheets[0]
  end
end
