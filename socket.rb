require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'audio.rb'

def get_called_old(ws)
    Feed.all({:feed_url => {"$ne" => nil} }).each do |feed|
        ws.send feed.refresh_feed
    end
end

class FeedFresher
    include EM::Deferrable

    def refresh_all_feeds
        Feed.all({:feed_url => {"$ne" => nil} }).each do |feed|
            feed.refresh_feed
        end
    end

    def refresh_feed( feed )
        feed.refresh_feed
    end
end
EM::WebSocket.start(:host => "0.0.0.0", :port => 9000, :debug => true) do |ws|
    puts 'init'
  ws.onopen    {
      puts 'open'
      ws.send "Refreshing feeds"
  }
  
  ws.onmessage do |msg| 
      Feed.all({:feed_url => { "$ne" => nil } } ).each do |feed|
         ws.send "sending #{feed.title}"
         ws.send  FeedFresher.new.refresh_feed(feed)
      end
  end
  
  ws.onclose   { puts "WebSocket closed" }

  ws.onerror { |e| puts "error: #{e.message}" }


  puts 'sever started?'
end
