# -*- coding: utf-8 -*-
require 'mechanize'

def handle_contact_data(list_elements)
  {}.tap do |response|
    list_elements.each do |elem|
      case elem.search("p").first.text.to_s
      when /Fon/
        response[:phone] = elem.search("p").last.text
      when /E.Mail/
        response[:email] =
          elem.search("a").attribute("href").value.
          sub(/','/, "@").sub(/^.+\('/,'').sub(/'\).*$/,'')
      when /Adresse/
        response[:addresse] = elem.search("p").last.text
      else
        puts "!!! Failed to match on: #{elem.search("p").first.text}"
      end
    end
  end
end

def handle_finance_view(row_elements)
  {}.tap do |response|
    row_elements.each do |row|
      response[row.search("td").first.text.sub(/:/,'')] =
        row.search("td").last.text
    end
  end
end

def extract_percent(investor_name)
  if investor_name =~ /\(([<]?[0-9]+)%\)/
    percent = $1
    [investor_name.sub(/[[:space:]+]\([<]?[0-9]+%\)/,''),percent]
  else
    [investor_name,"-"]
  end
end

namespace :scrape do
  desc <<-EOF
    Update the startups
  EOF
  task :update_startups do
    agent = Mechanize.new.tap do |agent|
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent.user_agent_alias = 'Linux Mozilla'
    end

    Startup.all.each do |startup|
      startup.update_from_url(agent) do |page, more_data|
        company_name = page.search("div.profile-additional-information").
          search("li").first.text
        more_data["company_name"] = company_name
      end rescue ""
    end

    Startup.all.select { |a| a.data.nil? }.each { |a| a.update(:data => {}) }

    Startup.all.map { |a| [a.data["E‑Mail:"],a] }.reject { |a,_| a.nil? }.
      each do |email,ent|
      ent.data["email"] =
        email.sub(/[[:space:]+]\[ät\][[:space:]+]/, '@').strip
      ent.data.delete("E‑Mail:")
      ent.save
    end

    Startup.all.select { |a| a.data.keys.include?("socials-googlePlus") }.
      each do |a|
      a.data["socials-googleplus"] = a.data["socials-googlePlus"]
      a.data.delete("socials-googlePlus")
      a.update(:data => a.data)
    end

    Startup.all.select { |a| a.data.keys.include?("socials-xing") }.
      each do |a|
      a.data["socials-xing"] = a.data["socials-xing"].sub(/;key/, "?key")
      a.save
    end
  end

  desc <<-EOF
    Update the entities
  EOF
  task :update_entities do
    agent = Mechanize.new.tap do |agent|
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent.user_agent_alias = 'Linux Mozilla'
    end
    Entity.all.each { |e| e.update_from_url(agent) rescue "" }

    Entity.all.select { |a| a.data.nil? }.each { |a| a.update(:data => {}) }

    Entity.all.select { |a| a.data.keys.include?("socials-googlePlus") }.
      each do |a|
      a.data["socials-googleplus"] = a.data["socials-googlePlus"]
      a.data.delete("socials-googlePlus")
      a.update(:data => a.data)
    end

    Entity.all.select { |a| a.data.keys.include?("socials-xing") }.
      each do |a|
      a.data["socials-xing"] = a.data["socials-xing"].sub(/;key/, "?key")
      a.save
    end

    Entity.all.map { |a| [a.data["E‑Mail:"],a] }.reject { |a,_| a.nil? }.
      each do |email,ent|
      ent.data["email"] =
        email.sub(/[[:space:]+]\[ät\][[:space:]+]/, '@').strip
      ent.data.delete("E‑Mail:")
      ent.save
    end
  end

  desc <<-EOF
    Scrape Startup data from Gruenderszene.
  EOF
  task :gruenderszene do
    agent = Mechanize.new.tap do |agent|
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent.user_agent_alias = 'Linux Mozilla'
    end

    ('a'..'z').each do |char|
      agent.
        get("#{GrSzBase}/datenbank/unternehmen/found/#{char}").
        search("ul.single-letter-list").search("li").each do |elem|

        src_url = GrSzBase + elem.search("a").attribute("href").value
        page = agent.get(src_url)
        name = page.search("h2.profile-name").text.strip
        logo_url =
          page.search("div.profile-image").search("img").attribute("src").value

        sector = page.search("p.teaser").text

        description = page.search("div.profile-description").children[3].text

        contact_data =
          handle_contact_data(page.search("div.contact-data").search("li"))

        finance_data =
          handle_finance_view(page.search("div.company-finance").search("tr"))

        founded = page.search("span.founded").text

        strtup = Startup.where(:url => src_url).first ||
          Startup.
          create({
                   :name        => name,
                   :url         => src_url,
                   :logo_url    => logo_url,
                   :sector      => sector,
                   :description => description,
                   :data        => finance_data.merge(:founded => founded)
                 })

        loc = begin
                Location.where(:email => contact_data[:email],
                               :phone => contact_data[:phone]).first ||
                  Location.create( :data  => contact_data,
                                   :phone => contact_data[:phone],
                                   :email => contact_data[:email],
                                   :kind  => "Headquarters")
              rescue
                nil
              end

        strtup.update(:location => loc)

        page.search("div#investor-view").search("li").map do |elem|
          elem.search("p")[1..-1]
        end.flatten.reject { |a| a.text.empty? }.map do |elem|
          { :url  => GrSzBase + elem.search("a").attribute("href").value,
            :text => elem.text
          }
        end.each do |hsh|
          investor_name, stake = extract_percent(hsh[:text])
          investor = Investor.where(:url => hsh[:url]).first ||
            Investor.create(:url => hsh[:url], :name => investor_name)

          Investment.where(:entity => investor, :startup => strtup).first ||
            Investment.create(:entity        => investor,
                              :startup       => strtup,
                              :stake_percent => stake.sub(/\)/,''))
        end

        puts "-"*30
        puts "Name:   #{name}"
        puts "Src:    #{src_url}"
        puts "Logo:   #{logo_url}"
        puts "Sector: #{sector}"
        puts "Desc:   #{description}"
        puts "Phone:  #{contact_data[:phone]}"
        puts "Email:  #{contact_data[:email]}"
        puts "Addres: #{contact_data[:addresse]}"
        puts "Financ: #{finance_data}"
        puts "Start:  #{founded}"

        page.search("div#team").search("li.head-list-item").map do |head|
          gruenderszene_link = GrSzBase +
            head.search("a").attribute("href")
          name = head.search("img").attribute("alt")
          image_url =
            head.search("img").attribute("src").to_s.
            sub(/\/thumb.php\?src=/,'').
            sub(/\&w=100\&h=132/,'')
          role = head.search("div.head-information").search("p").last.text

          puts ("+"*15) + " Employee " + ("+"*15)
          puts "Name: #{name}"
          puts "Link: #{gruenderszene_link}"
          puts "Img:  #{image_url}"
          puts "Role: #{role}"

          empl =
            Employee.where(:url => gruenderszene_link).first ||
            Employee.create(:url       => gruenderszene_link,
                            :name      => name,
                            :image_url => image_url)

          KeyEmployee.where(:entity => empl, :startup => strtup).first ||
            KeyEmployee.create(:entity  => empl,
                               :startup => strtup,
                               :role    => role)
        end

        # STDIN.gets
      end
    end
  end
end
