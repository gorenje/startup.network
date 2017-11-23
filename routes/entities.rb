get '/entities/mostinvestments/?:char?' do
  @char = params[:char].blank? ? "1" : params[:char]

  @mostinvestments = ActiveRecord::Base.connection.
    execute("select t.name, t.id, count(c.id) from entities as t, "+
            "investments as c where t.id = c.entity_id group by t.id "+
            generate_having(@char) + " order by count(c.id) desc;").to_a

  haml :entities_mostinvestments
end

get '/entities' do
  redirect("https://#{request.host}") if redirect_host_to_ssl?
  @entities = Entity.random(30).uniq(&:url)[0..11]
  haml :entities
end

get '/entities/:id' do
  redirect("https://#{request.host}") if redirect_host_to_ssl?

  @entity = Entity.find(params[:id])
  all_incarnations = @entity.all_incarnations

  @image_url = all_incarnations.map(&:image_url).compact.first

  @social_links = OpenStruct.new(:data => all_incarnations.map(&:data).
                                 compact.inject(&:merge))

  @investments = all_incarnations.map(&:investments).
    map(&:to_a).flatten.compact
  @key_employments = all_incarnations.map(&:key_employees).
    map(&:to_a).flatten.compact

  haml :entity
end
