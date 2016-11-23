require 'logger'
require 'json'
require 'bundler'
Bundler.require(:default, ENV["ENV"])

env       = ENV["ENV"]
output    = (env == "development") ? STDOUT : File.open('replies.log', File::WRONLY | File::APPEND | File::CREAT)
log       = Logger.new(output)
log.level = (env == "development") ? Logger::DEBUG : Logger::Info

log.info "Setting up Twitter connection..."
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end

log.info "Fetching advices file..."
advices_url = ENV["ADVICES_URL"]
log.info "URL: #{advices_url}"

advised = []
loop do
  begin
    # We run this inside the loop so we can pick up on new changes to the file.
    log.info "Parsing advices file..."
    advices_unparsed  = HTTParty.get(advices_url)
    advices           = JSON.parse(advices_unparsed).to_h

    log.info "RUNNING BOT!"
    rand_key = advices.keys.sample # Pull a random item from the advices dictionary to search for
    tweets   = client.search(rand_key).take(100) # Search for the keyword
    tweet    = tweets.sample # Pull a random search response

    unless ( advised.include? tweet.id )
      advice_to_give = advices[rand_key].sample
      full_tweet     = "@#{tweet.user.screen_name} #{advice_to_give}"

      client.update full_tweet, in_reply_to_status_id: tweet.id # Tweet reply.

      log.info "Original Tweet: #{tweet.user.screen_name} #{tweet.text}"
      log.info "Advice Given: #{full_tweet}"

      # Add the tweet we just replied to to the reply to dictionary
      advised << tweet.id

      # Chill out for a little bit, but tweet more frequently in the daytime (5 minutes daytime, 20 minutes after 5pm)
      if ( (8..17).include? Time.now.hour )
        sleep(300)
      else
        sleep(1200)
      end
    end

    # Look for mentions, and have a hard-coded response.  pretty much the same logic as above.
    my_replies = client.mentions_timeline
    my_replies.each do |reply|
      unless ( advised.include? my_reply )
        reply_to_give = "@#{reply.user.screen_name} I hope that you found my advice helpful!"
        client.update reply_to_give
        log.info reply_to_give
        advised << reply.id
      end
    end

    advised = [] if ( advised.length > 1000 )

  rescue => e
    log.error e
    next
  end
end
