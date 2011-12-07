(function($){

    // Models
    window.Feed = Backbone.Model.extend({
    
    });

    // Collections
    window.Feeds = Backbone.Collection.extend({
        model: Feed,
        url:   "/feeds"
    });

    window.feedlibrary = new Feeds();

$(document).ready( function() {
    // Views
    window.FeedView = Backbone.View.extend({
        tagName: 'section',
        className: 'feeds',

        initialize : function() {
            _.bindAll(this, 'render');
            _.templateSettings = {
                evalutate : /\/|(.+?)\|/g ,
                interpolate: /\|\|(.+?)\|\|/g
            },
            this.template = _.template( $('#feeds-template').html() );
            this.collection.bind( 'reset' , this.render );
        },

        render : function() {
           var $episodes,
                collection = this.collection;

            $(this.el).html( this.template({}) );
            $episodes = this.$('.episodes');

            collection.each( function(feed) {
               feed = feed.toJSON();
               $episodes.append( "<h3>" + feed.title + "</h3>" );   
            });
            
           return this;
        }

    });

    //window.FeedView = Backbone.View.extend({
    
    //});
    // Router
    
    window.FeedReader = Backbone.Router.extend({
        routes : {
            '' : 'home'
        },

        initialize : function() {
            this.podcastView = new FeedView({ 
                collection: window.library
            });
        },

        home : function() {
            var feeds = $("#feeds");
            feeds.empty();
            feeds.append( this.podcastView.render().el );
        }
    });

    // instantiate the router
        //window.library = window.feedlibrary.fetch();

        //Backbone.history.start();
});
})(jQuery);
