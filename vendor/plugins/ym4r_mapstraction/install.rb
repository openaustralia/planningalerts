require 'fileutils'

#Copy the Javascript files
FileUtils.copy(Dir[File.dirname(__FILE__) + '/javascript/*.js'], File.dirname(__FILE__) + '/../../../public/javascripts/')

#copy the gmaps_api_key file
gmaps_config = File.dirname(__FILE__) + '/../../../config/gmaps_api_key.yml'
unless File.exist?(gmaps_config)
  FileUtils.copy(File.dirname(__FILE__) + '/gmaps_api_key.yml.sample', gmaps_config)
end

#copy the map24_api_key file
map24_config = File.dirname(__FILE__) + '/../../../config/map24_api_key.yml'
unless File.exist?(map24_config)
  FileUtils.copy(File.dirname(__FILE__) + '/map24_api_key.yml.sample', map24_config)
end

#copy the mapquest_api_key file
mapquest_config = File.dirname(__FILE__) + '/../../../config/mapquest_api_key.yml'
unless File.exist?(mapquest_config)
  FileUtils.copy(File.dirname(__FILE__) + '/mapquest_api_key.yml.sample', mapquest_config)
end

#copy the multimap_api_key file
multimap_config = File.dirname(__FILE__) + '/../../../config/multimap_api_key.yml'
unless File.exist?(multimap_config)
  FileUtils.copy(File.dirname(__FILE__) + '/multimap_api_key.yml.sample', multimap_config)
end
