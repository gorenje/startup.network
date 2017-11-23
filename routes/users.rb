get '/login' do
  haml :login
end

get '/register' do
  haml :"login/email_register"
end

get '/logout' do
  session.delete(:user_id)
  redirect "/"
end

get '/profile' do
  must_be_logged_in

  @user           = User.find(session[:user_id])
  @offers_to_buy  = @user.offers.select { |a| a.is_a?(BidToBuy) }
  @offers_to_sell = @user.offers.select { |a| a.is_a?(OfferToSell) }

  haml :profile
end

post '/profile' do
  must_be_logged_in
  session[:message] = "Successfully updated profile"
  User.find(session[:user_id]).update(:name => params[:username])
  redirect "/profile"
end

%w(github xing linkedin twitter facebook google_oauth2).each do |oauth_provider|
  get "/login/#{oauth_provider}" do
    @email = session.delete(:email)
    redirect "/oauth/#{oauth_provider}"
  end
end

get '/login/email' do
  @email = session.delete(:email)
  haml :"login/email"
end

get '/resend/email/:eid' do
  if user = User.find_by_external_id(params[:eid])
    unless user.has_confirmed?
      if ENV["MANDRILL_API_KEY"].empty?
        session[:message] =
          "Mandrill not configured, <a href='"  +
          user.generate_email_confirmation_link +
          "'>Click here</a> to confirm email."
      else
        Mailer::Client.new.
          send_confirm_email({"confirm_link" =>
                              user.generate_email_confirmation_link,
                              "email"     => user.email,
                              "firstname" => user.name,
                              "lastname"  => ""})
        session[:message] = "Confirmation email resent."
      end
    else
      session[:message] = "Email already confirmed, <a href='/login/email'>"+
        "Login</a>."
    end
  else
    session[:message] = "Unknown User"
  end
  haml :"email_confirmation"
end

post '/login/:method' do
  if params[:method] == "email"
    key = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/,"\n"))
    data = JSON(JWE.decrypt(params[:creds], key))

    case data["type"]
    when "register"
      if u = User.where(:email => data["email"].downcase).first
        session[:message] = if u.has_confirmed?
                              "Email already registered, "+
                                "<a href='/login/email'>Login</a>."
                            else
                              "Email already registered, <a href='/resend/"+
                                "email/#{u.external_id}'>Resend Email</a>."
                            end

        @email = data["email"]
        @name  = data["name"]
      else
        if data["password1"] != data["password2"]
          session[:message] = "Passwords did not match"
          @email = data["email"]
          @name  = data["name"]
        else
          u = User.create(:email => data["email"].downcase,
                          :name  => data["name"])
          u.password = data["password1"]

          session[:message] =
            if ENV["MANDRILL_API_KEY"].empty?
              "Mandrill not configured, <a href='" +
              u.generate_email_confirmation_link   +
              "'>Click here</a> to confirm email."
            else
              Mailer::Client.new.
                send_confirm_email({"confirm_link" =>
                                    u.generate_email_confirmation_link,
                                    "email"     => u.email,
                                    "firstname" => u.name,
                                    "lastname"  => ""})
              "Thank You! Confirmation email has been sent."
            end
        end
      end

      haml :"login/email_register"

    when "login"
      if user = User.where(:email => data["email"].downcase).first
        if user.has_confirmed?
          if user.password_match?(data["password"])
            session[:user_id] = user.id
            redirect "/profile"
          else
            @email = data["email"]
            session[:message] =
              "Unknown Email or Wrong Password - take your pick"
          end
        else
          @email = data["email"]
          session[:message] =
            "Email not yet confirmed, check your inbox or <a href='/resend/"+
            "email/#{user.external_id}'>resend email</a>."
        end
      else
        @email = data["email"]
        session[:message] = "Unknown Email or Wrong Password - take your pick"
      end

      haml :"login/email"
    else
      redirect "/"
    end
  else
    @entity = Entity.find_user(params[:method], params[:url]).first
    redirect "/entities/#{@entity.id}" if @entity
  end
end

get '/users/email-confirmation' do
  session[:message] = params[:r]
  haml :"email_confirmation"
end

get '/user/emailconfirm' do
  if params_blank?(:email,:token)
    redirect to_email_confirm("MissingData")
  else
    email, salt = extract_email_and_salt(params[:email])
    if email.blank? or salt.blank?
      redirect to_email_confirm("DataCorrupt")
    end

    user = User.find_by_email(email)
    redirect(to_email_confirm("EmailUnknown")) if user.nil?

    if user.email_confirm_token_matched?(params[:token], salt)
      user.email_confirmed!
      session[:message] = "Email Confirmed!"
      session[:email] = user.email
      redirect "/login/email"
    else
      redirect to_email_confirm("TokenMismatch")
    end
  end
end
