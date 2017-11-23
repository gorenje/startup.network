post '/makeoffer/:id/sell' do
  must_be_logged_in

  inv = Investment.find(params[:id])
  OfferToSell.create(:amount     => params[:amount],
                     :investment => inv,
                     :user       => User.find(session[:user_id]),
                     :entity     => inv.entity)
  redirect "/offers"
end

post '/makeoffer/:id/buy' do
  must_be_logged_in

  inv = Investment.find(params[:id])
  BidToBuy.create(:amount     => params[:amount],
                  :investment => inv,
                  :user       => User.find(session[:user_id]),
                  :entity     => inv.entity)
  redirect "/offers"
end

get '/makeoffer/:id' do
  must_be_logged_in

  @investment = Investment.find(params[:id])
  haml :makeoffer
end

get '/offers' do
  must_be_logged_in

  @offers_to_sell = OfferToSell.all
  @offers_to_buy  = BidToBuy.all
  @user           = User.find(session[:user_id])

  haml :offers
end

get '/offers/edit/:id' do
  must_be_logged_in

  user = User.find(session[:user_id])
  @offer = Offer.find(params[:id])

  if user != @offer.user
    session[:message] = "Not your offer to edit"
    redirect "/offers"
  else
    haml :offer_edit
  end
end

post '/offers/edit/:id' do
  must_be_logged_in

  user = User.find(session[:user_id])
  ofr = Offer.find(params[:id])

  if user != ofr.user
    session[:message] = "Not your offer to edit"
  else
    ofr.update(:amount => params[:amount])
    ### TODO perhaps send email to the person ordering (OfferToBuy)
    ### TOOD or email to the people OfferingToSell (depending on offer type)
    session[:message] = "Offer successfully updated"
  end

  redirect "/offers"
end

get '/offers/accept/:id' do
  must_be_logged_in

  user = User.find(session[:user_id])
  ofr = Offer.find(params[:id])

  if ofr.user == user
    session[:message] = "Can not accept own offer"
  else
    ### TODO send email to the person making the offer
    ### TODO in the email include the person accepting and the
    ### TODO email of the person making the offer, i.e. send two emails.
    session[:message] = "Offer accepted, email has been sent."
  end

  haml :offer_accepted
end

get '/offers/delete/:id' do
  must_be_logged_in

  if ofr = Offer.find(params[:id])
    if ofr.user == User.find(session[:user_id])
      ofr.delete
      session[:message] = "Offer successfully deleted"
    else
      session[:message] = "Not your offer to delete"
    end
  else
    session[:message] = "Offer not found"
  end

  redirect request.referrer
end
