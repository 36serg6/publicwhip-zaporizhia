require 'open-uri'

namespace :load_mp do
  desc "Load mp"
  task :all => :environment do
    start_time = Time.now
    data_mps = JSON.load(open(Settings.source_data_url_deputies))
    data_mps.each do |m|
      if m["end_date"].nil?
        end_date = "9999-12-31"
      else
        end_date = m["end_date"]
      end
      mp = Mp.find_or_create_by(deputy_id: m["deputy_id"], first_name: m["first_name"], middle_name: m["middle_name"], last_name: m["last_name"], faction: m["faction"],  okrug: m["okrug"], start_date: m["start_date"])
      mp.update(end_date: end_date)
    end
    p "---> load_mp:all total time: " + Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")
  end
  desc "Load picture image deputy"
  task :image => :environment do
    start_time = Time.now
    mps = JSON.load(open(Settings.source_data_url_deputies))
    mps.each do |m|
      p m["photo_url"]
      photo = MiniMagick::Image.open(URI.encode(m["photo_url"]))
      photo.resize "200x200"
      photo.format 'png'
      photo.write("#{Rails.root}/public/image/#{m["deputy_id"]}.png")
    end
    p "---> load_mp:image total time: " + Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")
  end
end
