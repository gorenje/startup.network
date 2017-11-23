get '/role/:role_name' do
  must_be_logged_in

  @startups = KeyEmployee.
    by_role(params[:role_name]).uniq(&:startup_id).map {|a| a.startup }
  haml :startups_with_role
end

get '/roles' do
  must_be_logged_in

  @roles = ['ceo', 'cmo', 'cpo', 'cto', 'coo', 'cco', 'clo', 'cso', 'cio',
            'cpio', 'cfo'].map do |role_name|
    [role_name, KeyEmployee.by_role(role_name).count]
  end.sort_by { |_,a| a }.reverse

  haml :roles
end
