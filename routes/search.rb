post '/search' do
  handle_search(params[:term])
  haml :search_results
end

get '/search' do
  if params[:term].nil?
    haml :search_form
  else
    handle_search(params[:term])
    haml :search_results
  end
end
