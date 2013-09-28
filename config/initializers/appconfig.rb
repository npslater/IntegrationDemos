require 'ostruct'
require 'yaml'

all_config = YAML.load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result) || {}
env_config = all_config[Rails.env] || {}
AppConfig = OpenStruct.new(env_config)