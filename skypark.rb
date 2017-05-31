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
  parking_report_file = params["parking_report"]["tempfile"]
  license_report_file = params["license_report"]["tempfile"]
  parking_records = ParkingReportParser.new(parking_report_file).call
  license_records = LicenseReportParser.new(license_report_file).call
  report = ParkingReport.new(license_records, parking_records)
  report_data = report.call.sort {|a,b| a[0].downcase <=> b[0].downcase}
  locals = {
    :report_data => report_data,
    :license_plates => plate_reader.call,
    :unknown => ParkingReport::UNKNOWN,
    :users => report.users.size,
    :cars => report.cars.size,
    :unknown_cars => report.unknown_cars.size,
    :total => report.total,
    :csv_data => report.to_csv,
  }
  erb :report, layout: :layout, locals: locals
end
