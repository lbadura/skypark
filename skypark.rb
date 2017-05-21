require 'sinatra'
require_relative 'lib/skypark'

set :public_folder, File.dirname(__FILE__) + '/assets'

get '/' do
  license_plates = PlateReader.new.call
  erb :index, layout: :layout, locals: {:license_plates => license_plates}
end

post '/report' do
  file = params["report"]["tempfile"]
  parking_records = ParkingReportParser.new(file).call
  plate_reader = PlateReader.new
  report = ParkingReport.new(parking_records, plate_reader)
  report_data = report.call.sort {|a,b| a[0].downcase <=> b[0].downcase}
  erb :report, layout: :layout, locals: {:report_data => report_data, :license_plates => plate_reader.call, :unknown => ParkingReport::UNKNOWN}
end
