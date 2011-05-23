require 'rubygems'
require 'em-websocket'
require 'audio.rb'

def get_called(ws)
    Feed.all({:feed_url => {"$ne" => nil} }).each do |feed|
        ws.send feed.refresh_feed
    end
end
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
  ws.onopen    { ws.send "Refreshing feeds"}
  ws.onmessage do |msg| 
     get_called(ws)
  end
  ws.onclose   { puts "WebSocket closed" }
end
