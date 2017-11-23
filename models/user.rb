class User < ActiveRecord::Base
  has_many :offers

  include ModelHelpers::CredentialsHelper

  def self.find_by_external_id(eid)
    _,p,l,v = Base64::decode64(eid).split(/\|/)
    v =~ /.{#{p.to_i}}(.{#{l.to_i}})/
    find_by_id($1)
  end

  def external_id
    l = id.to_s.length
    p = rand(18-l)+1
    r = ("%020d" % rand.to_s.gsub(/^.+[.]/,'').to_i).
      gsub(/(.{#{p}}).{#{l}}(.+)/, "\\1#{id}\\2")
    Base64::encode64("eid|%03d|%03d|%s" % [p,l,r]).strip
  end

  def password=(val)
    self.creds = self.creds.merge("pass_hash" => Digest::SHA512.hexdigest(val))
  end

  def image_url=(val)
    self.creds = self.creds.merge("image_url" => val)
  end

  def add_to_profile_links(provider, val)
    plinks = self.creds["profile_links"] || []
    unless plinks.include?([provider,val])
      plinks << [provider,val]
      self.creds = self.creds.merge("profile_links" => plinks)
    end
  end

  def profile_links
    self.creds["profile_links"] || []
  end

  def image_url
    self.creds["image_url"]
  end

  def password_match?(val)
    c = self.creds
    val && c &&
      c["pass_hash"] && Digest::SHA512.hexdigest(val) == c["pass_hash"]
  end

  def generate_email_token(more_args = {})
    {}.tap do |p|
      p[:token]         = AdtekioUtilities::Encrypt.generate_token
      p[:salt]          = AdtekioUtilities::Encrypt.generate_salt
      p[:confirm_token] = AdtekioUtilities::Encrypt.generate_sha512(p[:salt], p[:token])

      # so the encoding of the email isnt always the same
      estr = { :email => email, :salt => p[:salt] }.merge(more_args).to_json
      p[:email] = AdtekioUtilities::Encrypt.encode_to_base64(estr)
    end
  end

  def generate_email_confirmation_link
    params = generate_email_token

    update(:salt             => nil,
           :has_confirmed    => false,
           :confirm_token    => params[:confirm_token])

    "#{$hosthandler.login.url}/user/emailconfirm?%s" % {
      :email => params[:email], :token => params[:token] }.to_query
  end

  def email_confirm_token_matched?(token, slt)
    confirm_token == AdtekioUtilities::Encrypt.generate_sha512(slt, token)
  end

  def to_hash
    JSON.parse(to_json)
  end

  def gravatar_image
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def user_image_url
    image_url || gravatar_image
  end

  def email_confirmed!
    update(:has_confirmed => true, :confirm_token => nil)
  end

  def entities_by_profile_links
    profile_links.map do |provider, url|
      SocialEntityLookup.where(:provider => provider, :url => url).all
    end.flatten.map { |a| a.entity }
  end
end
