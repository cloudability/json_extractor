require 'json'
$:.unshift(File.dirname(__FILE__))
require 'json_extractor/json_extractor'

module JSONExtractor
  def self.subdocument(filename, key)
    JSON.parse(extract_subdocument(filename, key))
  end
end
