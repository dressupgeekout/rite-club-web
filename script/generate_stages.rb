# Use this script to generate the stage ("match site") data.

require 'nokogiri'
require 'yaml'

HELPTEXT_EN_XML_PATH = ARGV.shift

doc = Nokogiri::XML(File.read(File.expand_path(HELPTEXT_EN_XML_PATH)))

ary = []

%w[A B C D E F G H I J].each { |x|
  e = doc.xpath(sprintf('//HelpText/Text[@Id="MatchSite%s"]', x)).first
  h = {
    :match_site => x,
    :name => e.get_attribute("DisplayName"),
  }
  ary.push(h)
}

File.open("data/stages.yaml", "w") { |f| f.puts(YAML.dump(ary)) }
