require 'sinatra'
require_relative 'lib/skypark'

set :public_folder, File.dirname(__FILE__) + '/assets'

get '/' do
  license_plates = PlateReader.new.call
  erb :index, layout: :layout, locals: {:license_plates => license_plates}
end

post '/report' do
  file = params["report"]["tempfile"]
  parsed_data = ParkingReportParser.new(file).call
end
