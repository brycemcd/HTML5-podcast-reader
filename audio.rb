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
end

class Feed
    include MongoMapper::Document
    many :entries

    key :title
    key :last_updated, DateTime
    timestamps!
    
    def self.import_feed( url )
        feed = FeedNormalizer::FeedNormalizer.parse open( url )
        nf = self.new( :title => feed.title )
        feed.entries[0..3].each { |e| nf.entries << Entry.new_from_feed( e ) }
        nf.save!
    end
end

class Entry
    include MongoMapper::EmbeddedDocument

    key :title
    key :authors, Array
    key :content
    key :urls,  Array
    key :date_published, DateTime
    key :stream
    key :playhead, String, :default => 0

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


helpers do
    def get_stream( stream )
       obj_id = BSON::ObjectId( stream )
       feed = Feed.first( "entries._id" => obj_id )
       feed.entries.select { |f| f._id == obj_id}.first
    end
end

get "/" do
    last_played = CurrentPlay.first || CurrentPlay.new
    @stream = get_stream( last_played.stream ) || Entry.new
    @feeds = Feed.all
    erb :index
end

get "/get-stream" do
    @stream = get_stream( params[:stream] )
    if @stream
       @stream.to_json
    else
        Entry.new
    end
end

get "/played" do
    cp = CurrentPlay.first || CurrentPlay.new
    cp.update_attributes( :stream => params[:stream] )
    @stream = get_stream( params[:stream] )
    puts @stream.inspect
    @stream.update_attributes(:playhead => params[:time] )
end
