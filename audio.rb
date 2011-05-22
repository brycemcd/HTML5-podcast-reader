require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'feed-normalizer'
require 'open-uri'
require 'json'

Mongo::Connection.new("localhost")
MongoMapper.database = "podcaster"

class CurrentPlay
    include MongoMapper::Document

    key :stream
    key :playhead
end

class Feed
    include MongoMapper::Document
    many :entries

    key :title
    key :last_updated, DateTime
    timestamps!

end

class Entry
    include MongoMapper::EmbeddedDocument

    key :title
    key :authors, Array
    key :content
    key :urls,  Array
    key :date_published, DateTime
    key :stream

    def self.new_from_feed( feed )
        self.new(
            :title => feed.title, 
            :authors => feed.authors, 
            :content => feed.content, 
            :urls => feed.urls, 
            :date_published => feed.date_published , 
            :stream => feed.enclosures.first.url
        )
    end
end

get "/" do
    @stream = CurrentPlay.last || CurrentPlay.new
    @feeds = Feed.all
    erb :index
end
get "/get-stream" do
    puts params[:stream]
    feed = Feed.first( {"entries.stream" => params[:stream] })
    @stream = feed.entries.select { |f| f.stream == params[:stream] }
    if @stream
        @stream.to_json
    else
        Entry.new
    end
end
get "/played" do
    @stream = CurrentPlay.first_or_create(:stream => params[:stream] )
    @stream.set(:playhead => params[:time] )
    puts @stream.inspect
end
