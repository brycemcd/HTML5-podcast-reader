(function($){

    // Models
    window.Feed = Backbone.Model.extend({
    
    });

    window.Episode = Backbone.Model.extend({
    
    });

    // Collections
    window.Feeds = Backbone.Collection.extend({
        model: Feed,
        url:   "/feeds"
    });

    window.feedlibrary = new Feeds();

$(document).ready( function() {
    // Views
    window.AllFeedsView = Backbone.View.extend({
        tagName: 'div',
        className: 'feeds',
        template : _.template( $('#feeds-template').html() ),
        

        initialize : function() {
            _.bindAll(this, 'render');
            this.collection.bind( 'reset' , this.render );
        },

        render : function() {
            var $all_feeds = $(this.el);
            collection = this.collection;
            $(this.el).append( this.template );
            //var allfeeds = this.template( f = collection.toJSON() );
            //$(this.el).html(  allfeeds  );
            //$episodes = this.$('.episodes');

            collection.each( function(feed) {
                var feedview = new FeedView({
                    model : feed,
                    collection : this.collection
                });
                // 
               //feed = feed.toJSON();
               //$all_feeds.append( "<h3>" + feed.title + "</h3>" );   
               $all_feeds.append( feedview.render().el );
            });
            
           return this;
        }

    });

    window.FeedView = Backbone.View.extend({
        tagName: 'section',
        className: 'feed',
        template : _.template( $('#feed-template').html() ),

        initialize : function() {
            _.bindAll(this, 'render');
            this.collection.bind( 'reset' , this.render );
        },

        render : function() {
            feed = this.template( this.model.toJSON() );
            $(this.el).html( feed );
            $episodes = $('.episodes');

            console.log( this.model.toJSON().entries );
            //this.model.toJSON().entries.each( function( episode ){
                //var epiview= new EpisodesView({
                    //model : episode,
                    //collection : this.collection
                //});
                // 
               //feed = feed.toJSON();
               //$all_feeds.append( "<h3>" + feed.title + "</h3>" );   
               //console.log( episode.toJSON() );
               $episodes.append( epiview.render().el );
            //});
           return this;
        }
    
    });

    window.EpisodesView = Backbone.View.extend({
        tagName: 'li',
        className: 'episodes',
        template : _.template( $('#episodes-template').html() ),

        initialize : function() {
            _.bindAll(this, 'render');
            this.collection.bind( 'reset' , this.render );
        },

        render : function() {
            episode = this.template( this.model.toJSON() );
            $(this.el).html(  episode );

            return this;
        }
    });
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
