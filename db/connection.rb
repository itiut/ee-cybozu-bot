require 'erb'
require 'sequel'
require 'yaml'

config = YAML.load(ERB.new(File.read(File.expand_path('../../config/database.yml', __FILE__))).result)[ENV['HEROKU_ENV']]
DB = Sequel.connect(config)
