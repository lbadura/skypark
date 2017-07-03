require 'sinatra'
require_relative 'lib/skypark'

set :public_folder, File.dirname(__FILE__) + '/assets'
set :threaded, true
set :server, :puma

get '/' do
  license_plates = PlateReader.new.call
  erb :index, layout: :layout, locals: {:license_plates => license_plates}
end

post '/report' do
  parking_report_file = params["parking_report"]["tempfile"] if params["parking_report"]
  license_report_file = params["license_report"]["tempfile"] if params["license_report"]
  parking_records = ParkingReportParser.new(parking_report_file).call if parking_report_file
  license_records = LicenseReportParser.new(license_report_file).call if license_report_file
  report = ParkingReport.new(license_records, parking_records)
  parking_report_rows = report.call.sort {|a,b| a.owner.downcase <=> b.owner.downcase}
  locals = {
    :license_plates => PlateReader.new.call,
    :parking_report_rows => parking_report_rows,
    :license_plate_count => report.license_plates.count,
    :unknown_license_plate_count => report.unknown_license_plates.count,
    :owner_count => report.owners.size,
    :total => report.total,
    :csv_data => report.to_csv,
  }
  erb :report, layout: :layout, locals: locals
end
