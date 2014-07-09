module RSpotify

  class User < Base

    # Returns User object with id provided
    #
    # @param id [String]
    # @return [User]
    #
    # @example
    #           user = RSpotify::User.find('wizzler')
    #           user.class #=> RSpotify::User
    #           user.id    #=> "wizzler"
    def self.find(id)
      super(id, 'user')
    end

    # Spotify does not support search for users. Prints warning and returns false
    def self.search(*)
      warn 'Spotify API does not support search for users'
      false
    end

    def self.oauth_headers(user_id)
      { 
        'Authorization' => "Bearer #{@@users_credentials[user_id]['token']}",
        'Content-Type'  => 'application/json'
      }
    end
    private_class_method :oauth_headers

    def initialize(options = {})
      credentials = options['credentials']
      options     = options['info'] if options['info']

      @country      ||= options['country']
      @display_name ||= options['display_name']
      @email        ||= options['email']
      @images       ||= options['images']
      @product      ||= options['product']

      super(options)

      if credentials
        @@users_credentials ||= {}
        @@users_credentials[@id] = credentials
      end
    end

    # Creates a playlist in user's Spotify account. This method is only available when the current user
    # has granted access to the *playlist-modify* and *playlist-modify-private* scopes.
    #
    # @param name [String] The name for the new playlist
    # @param public [Boolean] Whether the playlist is public or private. Default: true
    # @return [Playlist]
    #
    # @example
    #           user.create_playlist!('my-first-playlist')
    #           user.playlists.last.name   #=> "my-first-playlist"
    #           user.playlists.last.public #=> true
    #
    #           playlist = user.create_playlist!('my-second-playlist', public: false)
    #           playlist.name   #=> "my-second-playlist"
    #           playlist.public #=> false
    def create_playlist!(name, public: true)
      url = "users/#{@id}/playlists"
      request_data = %Q({"name":"#{name}", "public":#{public}})
      Playlist.new RSpotify.post(url, request_data, User.send(:oauth_headers, @id))
    end

    # Returns all playlists from user
    #
    # @return [Array<Playlist>]
    #
    # @example
    #           playlists = user.playlists
    #           playlists.class       #=> Array
    #           playlists.first.class #=> RSpotify::Playlist
    #           playlists.first.name  #=> "Movie Soundtrack Masterpieces"
    def playlists
      playlists = RSpotify.auth_get("users/#{@id}/playlists")['items']
      playlists.map { |p| Playlist.new p }
    end
  end
end
