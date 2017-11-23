%w(get post).each do |method|
  send(method, "/oauth/:provider/callback") do
    if auth_hsh = env['omniauth.auth']
      if auth_hsh["info"] && !auth_hsh["info"]["email"].blank? &&
          (user = User.where(:email=>auth_hsh["info"]["email"]).first_or_create)
        session[:user_id] = user.id

        urls = auth_hsh["info"]["urls"]
        profile_link = case params[:provider]
                       when "github" then urls["GitHub"]
                       when "linkedin" then urls["public_profile"]
                       when "facebook" then fb_plink(auth_hsh["uid"])
                       else
                         nil
                       end

        user.
          add_to_profile_links(params[:provider],profile_link) if profile_link
        user.email_confirmed!
        user.image_url = auth_hsh["info"]["image"]

        redirect "/profile"
      end
    end

    if params[:provider] == "twitter"
      session[:message] = "Twitter does not provider user specific information"
    end
    redirect "/login"
  end
end

get '/oauth/failure' do
  session[:message] = params[:message]
  session.delete(:user_id)
  redirect '/login'
end
