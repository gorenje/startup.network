module ViewHelpers
  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def redirect_host_to_www?
    !(request.host =~ /^www[.]/) &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def view_exist?(path)
    File.exists?(File.dirname(__FILE__)+"/../views/#{path}.haml")
  end

  def fb_plink(fbid)
    "https://www.facebook.com/#{fbid}"
  end

  def handle_search(term)
    entities = Entity.search(term)
    @investors = entities.select { |e| e.is_a?(Investor) }
    @employees = entities.select { |e| e.is_a?(Employee) }
    @startups = Startup.search(term).to_a
  end

  def generate_having(char)
    if char =~ /^([0-9]+)$/
      "having count(c.id) = #{$1}"
    elsif char =~ /^([0-9]+)-([0-9]+)$/
      "having count(c.id) >= #{$1} and count(c.id) <= #{$2}"
    elsif char =~ /^[>]([0-9]+)$/
      "having count(c.id) > #{$1}"
    else
      "having count(c.id) = 0"
    end
  end

  def extract_email_and_salt(encstr)
    estr = begin
             AdtekioUtilities::Encrypt.decode_from_base64(encstr)
           rescue
             begin
               AdtekioUtilities::Encrypt.decode_from_base64(CGI.unescape(encstr))
             rescue
               "{}"
             end
           end
    # this is a hash: { :email => "fib@fna.de", :salt => "sddsdad" }
    # so sorting and taking the last will give: ["fib@fna.de","sddsdad"]
    JSON.parse(estr).sort.map(&:last) rescue [nil,nil]
  end

  def to_email_confirm(s)
    "#{$hosthandler.login.url}/users/email-confirmation?r=#{s}"
  end

  def params_blank?(*args)
    args.any? { |a| params[a].blank? }
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def must_be_logged_in
    redirect "/login" unless is_logged_in?
  end
end
