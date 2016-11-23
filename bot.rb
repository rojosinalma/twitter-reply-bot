require 'logger'
require 'json'
require 'bundler'
Bundler.require(:default, ENV["ENV"])

# No touchy, just looky... unless you know wtf you're doing (and Ruby).
advices_url = ENV["ADVICES_URL"]
env         = ENV["ENV"]
output      = (env == "development") ? STDOUT : File.open('replies.log', File::WRONLY | File::APPEND | File::CREAT)
log         = Logger.new(output)
log.level   = (env == "development") ? Logger::DEBUG : Logger::Info

log.info "Setting up Twitter connection..."
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end

advised = []
log.info "RUNNING BOT!"
loop do
  # If for whatever reason this fails, we really wanna fail hard.
  # But we run it inside the loop to pick up on new changes to the file.
  log.info "Fetching advices file (#{advices_url})..."
  advices_unparsed  = HTTParty.get(advices_url)

  log.info "Parsing advices file..."
  advices           = JSON.parse(advices_unparsed).to_h

  begin
    rand_key = advices.keys.sample # Pull a random item from the advices dictionary to search for
    tweets   = client.search(rand_key).take(100) # Search for the keyword
    tweet    = tweets.sample # Pull a random search response

    unless ( advised.include? tweet.id )
      advice_to_give = advices[rand_key].sample # Based on the random key, get a random advice.
      full_tweet     = "@#{tweet.user.screen_name} #{advice_to_give}"

      log.info "Original Tweet: #{tweet.user.screen_name} #{tweet.text}"
      log.info "Advice Given: #{full_tweet}"

      # Tweet reply.
      unless env == "development"
        log.info "TWEETING ADVISE: #{full_tweet}"
        client.update full_tweet, in_reply_to_status_id: tweet.id
      end

      # Add the tweet we just replied to, to the reply dictionary
      advised << tweet.id

      # Chill out for a little bit, but tweet more frequently in the daytime (5 minutes daytime, 20 minutes after 5pm)
      if ( (8..17).include? Time.now.hour )
        sleep(300)
      else
        sleep(1200)
      end
    end

    # Look for mentions and reply back, pretty much the same logic as above.
    my_replies = client.mentions_timeline
    my_replies.each do |reply|
      unless ( advised.include? reply )
        # Prepare the reply back, the reply is stored as the "reply_back" key in the .json file.
        reply_to_give = "@#{reply.user.screen_name} #{advices["reply_back"]}"

        log.info "Original Reply: #{tweet.user.screen_name} #{reply.text}"
        log.info "Reply back: #{reply_to_give}"

        unless env == "development"
          log.info "TWEETING REPLY: #{reply_to_give}"
          client.update reply_to_give
        end

        advised << reply.id
      end
    end

    if ( advised.length > 100 )
      log.info "Clearing the advised list..."
      advised = []
    end

  rescue => e
    log.error e
    break if e.is_a? Twitter::Error
    next
  end
end
