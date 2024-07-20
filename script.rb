require 'net/http'
require 'uri'
require 'securerandom'
require 'json'

raw = File.read('links.md').split "\n"

# PROJECT_ID = "2299442309" # Test
# PROJECT_ID = "2209772454" # Inbox
PROJECT_ID = "2299443491" # Later
TODOIST_TOKEN = "0c7828c245efa04315f23790980f2e7ebdb8fd31"

def add_task(line, description = nil)
  uri = URI('https://api.todoist.com/rest/v2/tasks')
  req = Net::HTTP::Post.new(uri)
  req["Content-Type"]= "application/json"
  req["X-Request-Id"]= SecureRandom.uuid
  req["Authorization"] = "Bearer #{TODOIST_TOKEN}"
  req.body = { "content" => line, "project_id" => PROJECT_ID, "description" => description }.to_json
  res = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: uri.scheme == 'https' }) do |http|
    http.request(req)
  end
end

created = 0
for line in raw
  # Remove "- " from the beginning of the line
  line = line.strip[2..-1]

  if /^\[(.+)\]\((.+)\)$/.match(line)
    match = line.match(/^\[(.+)\]\((.+)\)$/)
    add_task match[1], match[2]
  elsif /^\<(.+)\>$/.match(line)
    link = line.match(/^\<(.*)\>$/)[1]
    add_task link
  else
    add_task line
  end

  created += 1
  percent = created / raw.length.to_f * 100
  STDOUT.write "\rProgress => #{created} / #{raw.length} | #{percent.round(0)}%"
end

puts ""

