get '/' do
  # La siguiente linea hace render de la vista 
  # que esta en app/views/index.erb

  erb :index
end

post '/fetch' do
	handle = params[:twitter_handle]
	redirect to("/#{handle}")
end

get '/:username' do

	@handle = params[:username]
	@user = TwitterUser.find_or_create_by(username: @handle)
  # Se crea un TwitterUser si no existe en la base de datos de lo contrario trae de la base al usuario.

  tweets = Tweets.where(twitter_user_id: @user.id)
  # cosa = tweets[0].id
  # puts "este es el id: #{cosa}"
  if tweets.empty?
  	tweets = TWITTER.user_timeline(username: @user.username)
  	tweets.each do  |t|

  		Tweets.create(twitter_user_id: @user.id, tweet: t.text, tweet_id: t.id.to_s)
  	end
   # La base de datos no tiene tweets?
   # Pide a Twitter los últimos tweets del usuario y los guarda en la base de datos
  end

  if Time.now - tweets.first.created_at > 2000
    puts "estamos pidiento tweets"
    tweets = TWITTER.user_timeline(username: @user.username)
    tweets.each do  |t|
      Tweets.create(twitter_user_id: @user.id, tweet: t.text, tweet_id: t.id.to_s)
    end

    # Pide a Twitter los últimos tweets del usuario y los guarda en la base de datos
  end

  @tweets = Tweets.all.order(:created_at).limit(10)
  # Se hace una petición por los ultimos 10 tweets a la base de datos. 
  erb :tweets
end

post '/tweet' do
  @message = nil
    # Recibe el input del usuario
  tweet = params[:tweet]
  begin
    TWITTER.update!(tweet)
    @message = "el tweet se envio con exito"
  rescue
    @message = "el tweet ya se envio antes"
  end
  erb :index
end



