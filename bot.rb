require 'logger'
require 'json'
require 'twitter'

file      = File.open('replies.log', File::WRONLY | File::APPEND)
logger    = Logger.new(file)
log.level = Logger::WARN

# Setup
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "YOUR_CONSUMER_KEY"
  config.consumer_secret     = "YOUR_CONSUMER_SECRET"
  config.access_token        = "YOUR_ACCESS_TOKEN"
  config.access_token_secret = "YOUR_ACCESS_SECRET"
end

advice = {
  "need haircut": [
    "A pixie cut would look good on you.",
    "Just get an up-do.",
    "Bangs are coming back!",
    "Just grow it out!",
    "Don't cut it, just get a blow out"
  ]
}

advised = []
loop do
  begin
    rand_key = advice.keys.sample # Pull a random item from the advice dictionary to search for
    tweets   = client.search(rand_key).take(100) # Search for the keyword
    tweet    = tweets.sample # Pull a random search response

    unless ( advised.include? tweet.id )
      advice_to_give = advice[a].sample
      full_tweet     = "@#{tweet.user.screen_name} #{advice_to_give}"

      api.update full_tweet, in_reply_to_status_id: tweet.id # Tweet reply.

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
        client.update "@#{reply.user.screen_name} I hope that you found my advice helpful!"
        log.info "@#{reply.user.screen_name} I hope that you found my advice helpful!\n"
        advised << reply.id
      end
    end

    advised = [] if ( advised.length > 1000 )

  rescue => e
    log.error e
    next
  end
end
