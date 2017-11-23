GrSzBase = "http://www.gruenderszene.de"
DefaultEntityImage =
  "http://www.gruenderszene.de/datenbank/uploads/thumb-kopf-100x132.png"

LoginProviders = {
  :email         => ["Email",    "email2",     false],
  :xing          => ["Xing",     "xing2",      true],
  :google_oauth2 => ["Google",   "googleplus", false],
  :facebook      => ["Facebook", "facebook4",  false],
  :linkedin      => ["LinkedIn", "linkedin2",  false],
  :twitter       => ["Twitter",  "twitter",    false],
  :github        => ["GitHub",   "github",     false]
}

OauthProviders = {
  :github        => { :scope => "user" },
  :xing          => {},
  :linkedin      => { :scope => 'r_basicprofile r_emailaddress' },
  :twitter       => {},
  :facebook      => { :scope => "email" },
  :google_oauth2 => { :scope => 'email, profile, plus.me' },
}

MenuItems = {
  "Startups" => "/startups",
  "People"   => "/entities",
}

# Remove all those login possibilites that don't have configuration.
OauthProviders.keys.each do |key|
  LoginProviders[key][2] = ENV["#{key.to_s.upcase}_KEY"].empty? ||
                           ENV["#{key.to_s.upcase}_SECRET"].empty?
end
