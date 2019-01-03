# Use this script to generate the triumvirate data.

require 'nokogiri'
require 'yaml'

HELPTEXT_EN_XML_PATH = ARGV.shift

doc = Nokogiri::XML(File.read(File.expand_path(HELPTEXT_EN_XML_PATH)))

ary = []

(1..11).each { |n|
  e = doc.xpath(sprintf('//HelpText/Text[@Id="TeamName%02d"]', n)).first
  h = {
    :team_index => n,
    :name => e.get_attribute("DisplayName"),
  }
  ary.push(h)
}

File.open("data/triumvirates.yaml", "w") { |f| f.puts(YAML.dump(ary)) }
