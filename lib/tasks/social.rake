namespace :social do
  desc <<-EOF
    Update the social entity lookup table.
  EOF
  task :update do
    map_to_provider = {
      "googleplus" => "google_oauth2"
    }
    Entity.all.each do |entity|
      entity.data.each do |key, value|
        next unless key =~ /^socials-(.+)/ || key =~ /(email)/i
        provider = $1.downcase
        provider = map_to_provider[provider] || provider

        SocialEntityLookup.where(:provider => provider,
                                 :url      => value,
                                 :entity   => entity).first_or_create
      end
    end
  end
end
