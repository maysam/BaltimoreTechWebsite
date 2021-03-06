require 'date'
require 'yaml'
require 'json'
require 'open-uri'
require 'fileutils'

TOKEN = "4a2f9464b2749587b6c26557a59268"

meetup_folder = '_data/meetups/'
events_folder = '_data/events/'
Dir.entries(meetup_folder).select {|f| !File.directory? f}.each do |meetup_file|
  begin
    file = "#{meetup_folder}#{meetup_file}"
    data = YAML::load open(file)
    url = data['url']
    p url
    usable = url.split(/www.meetup.com|\//).last
    source = "https://api.meetup.com/#{usable}/events/?key=#{TOKEN}"

    raw = open(source).read
    data = JSON.parse(raw)
    data.each do |event|
      slug = event['id']
      date = Date.parse event['local_date']
      year = date.year
      month = date.month
      FileUtils.mkdir_p("#{events_folder}#{year}")
      FileUtils.mkdir_p("#{events_folder}#{year}/#{month}")
      File.open("#{events_folder}#{year}/#{month}/#{slug}.yml", "w") { |file| file.write(event.to_yaml)}
    end
  rescue StandardError => error
    p error.backtrace
  end
end
