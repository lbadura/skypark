require 'pry'
require 'csv'
require 'dotenv'
require_relative 'plate_reader'
require_relative 'parking_record'
require_relative 'parking_report_parser'
require_relative 'parking_report'

Dotenv.load

module Skypark
  REGISTRY_FILE_KEY = ENV['REGISTRY_FILE_KEY']
  GOOGLE_CREDENTIALS_FILE = ENV['GOOGLE_CREDENTIALS_FILE']
end
