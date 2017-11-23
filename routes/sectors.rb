get '/sectors/?:char?' do
  must_be_logged_in

  @char = if params[:char].blank?
            ['A', 'a']
          elsif params[:char] == '0-9'
            ('0'..'9').to_a
          else
            [params[:char].upcase,params[:char].downcase]
          end

  @sectors = Startup.all.map { |a| [a.sector.strip, a] }.
    reject { |s,_| s.nil? || s.strip.empty? }.
    select { |s,_| @char.include?(s.first) }.
    group_by { |a,_| a }.sort_by { |a,_| a.downcase }

  haml :sectors
end
