require 'mapstraction_plugin/mapping'
require 'mapstraction_plugin/mapstraction'
require 'mapstraction_plugin/overlay'
require 'mapstraction_plugin/helper'

module Ym4r
  module MapstractionPlugin
    class GMapsAPIKeyConfigFileNotFoundException < StandardError
    end
    class Map24APIKeyConfigFileNotFoundException < StandardError
    end
    class MapquestAPIKeyConfigFileNotFoundException < StandardError
    end
    class MultimapAPIKeyConfigFileNotFoundException < StandardError
    end
    
    unless File.exist?(RAILS_ROOT + '/config/gmaps_api_key.yml')
      raise GMapsAPIKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/gmaps_api_key.yml not found")
    else
      GMAPS_API_KEY = YAML.load_file(RAILS_ROOT + '/config/gmaps_api_key.yml')[ENV['RAILS_ENV']]
    end
    
    unless File.exist?(RAILS_ROOT + '/config/map24_api_key.yml')
      raise Map24APIKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/map24_api_key.yml not found")
    else
      MAP24_API_KEY = YAML.load_file(RAILS_ROOT + '/config/map24_api_key.yml')[ENV['RAILS_ENV']]
    end

    unless File.exist?(RAILS_ROOT + '/config/mapquest_api_key.yml')
      raise MapquestAPIKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/mapquest_api_key.yml not found")
    else
      MAPQUEST_API_KEY = YAML.load_file(RAILS_ROOT + '/config/mapquest_api_key.yml')[ENV['RAILS_ENV']]
    end

    unless File.exist?(RAILS_ROOT + '/config/multimap_api_key.yml')
      raise MultimapAPIKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/multimap_api_key.yml not found")
    else
      MULTIMAP_API_KEY = YAML.load_file(RAILS_ROOT + '/config/multimap_api_key.yml')[ENV['RAILS_ENV']]
    end
  end
end

include Ym4r::MapstractionPlugin
