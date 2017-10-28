A Ruby script that scrapes your podcasts from the Overcast app and uses iTunes
subscription data to recommend new podcasts you might like.

### Usage

You must set the constants `OVERCAST_EMAIL` and `OVERCAST_PASSWORD` to your account login info.
Run `ruby ./more_pods.rb` inside the project directory.

### Dependencies

* `Typhoeus` for parallel HTTP requests
* `Mechanize` for logging in to your Overcast account
* `Nokogiri` for parsing HTML