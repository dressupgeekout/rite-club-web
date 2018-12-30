require 'net/http'

uri = URI("http://localhost:9292/api/v1/rites")

req = Net::HTTP::Post.new(uri)
req.body = File.read(File.join(__dir__, "..", "testdata", "rite01.json"))

Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
end
