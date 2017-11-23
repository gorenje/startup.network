get '/startups/mostinvestors/?:char?' do
  must_be_logged_in

  @char = params[:char].blank? ? "1" : params[:char]

  @mostinvestors = ActiveRecord::Base.connection.
    execute("select t.name, t.id, count(c.id) from startups as t, " +
            "investments as c where t.id = c.startup_id group by t.id " +
            generate_having(@char) + "order by count(c.id) desc;")
  haml :startups_mostinvestors
end

get '/startups' do
  @startups = Startup.random(12)
  haml :startups
end

get '/startups/:id' do
  @startup = Startup.find(params[:id])
  haml :startup
end
