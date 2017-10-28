require 'mechanize'
require 'nokogiri'
require 'typhoeus'

# get podcasts from overcast
OVERCAST_EMAIL    = 'YOUR_EMAIL'
OVERCAST_PASSWORD = 'YOUR_PASSWORD'

puts 'logging in to your Overcast account...'
agent = Mechanize.new
page = agent.get('https://overcast.fm/login')

form = page.form
form.email = OVERCAST_EMAIL
form.password = OVERCAST_PASSWORD
page = agent.submit(form)

# scrape my podcast info and build the correct itunes urls
puts 'scraping your podcast data...'
paths = page.search('a.feedcell').map { |link| link['href'] }
my_podcast_ids = paths.grep(/itunes(\d+)\//) { $1 }
itunes_podcast_urls = paths.grep(/itunes(\d+)\/(.+)/) do
   podcast_id, slug = $1, $2
   "https://itunes.apple.com/us/podcast/#{slug}/id#{podcast_id}?mt=2"
end

# scrape the podcasts from itunes
puts 'scraping podcasts from itunes...'
hydra = Typhoeus::Hydra.new
responses = []

itunes_podcast_urls.each do |url|
  request = Typhoeus::Request.new(url)

  request.on_complete do |response|
    responses << response
  end

  hydra.queue(request)
end

hydra.run

# parse the related subscription info
puts 'aggregating related podcast data...'
results = responses.flat_map do |response|
  doc = Nokogiri::HTML(response.body)
  doc.css('.lockup.small.podcast.audio').map do |podcast_node|
    title = podcast_node.attributes['preview-title'].value
    id    = podcast_node.attributes['adam-id'].value
    [title, id]
  end
end

# order podcasts by how many of my podcasts they're related to
puts 'Here are some podcasts you might enjoy:'
pp results
    .reject { |result| my_podcast_ids.include?(result.last) }
    .map(&:first)
    .sort
    .chunk { |x| x }
    .map { |title, titles| [title, titles.size] }
    .sort_by(&:last)
    .reverse
    .take(10)