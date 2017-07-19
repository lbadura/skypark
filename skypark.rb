require 'rubygems'
require 'bundler'
require 'sinatra'
require 'omniauth'
require 'omniauth/google_oauth2'
require 'dotenv'
require_relative 'lib/skypark'

Dotenv.load

set :public_folder, File.dirname(__FILE__) + '/assets'
set :threaded, true
set :server, :puma
enable :sessions
set :session_secret, 'ip3GvYH3hLAMQ'

use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_AUTH_CLIENT_ID'], ENV['GOOGLE_AUTH_SECRET_ID'], access_type: 'offline', prompt: 'consent', provider_ignores_state: true, scope: 'email,profile'
end

%w(get post).each do |method|
  send(method, "/auth/:provider/callback") do
    if auth = request.env['omniauth.auth']
      session[:user_id] = auth['info']['email']
      session[:name] = auth['info']['name']
      redirect '/'
    else
      redirect '/auth/failure'
    end
  end
end

get '/auth/failure' do
  'Unauthorized'
end

get '/' do
  redirect '/login' unless session[:user_id]
  license_plates = PlateReader.new.call
  erb :index, layout: :layout, locals: {:license_plates => license_plates, :user_name => session[:name]}
end

get '/login' do
  erb :login, layout: nil
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
    :department_report => report.by_department,
    :owner_count => report.owners.size,
    :total => report.total,
    :csv_data => report.to_csv,
    :user_name => session[:name],
  }
  erb :report, layout: :layout, locals: locals
end
