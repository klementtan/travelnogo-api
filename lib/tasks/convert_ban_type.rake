
controller_absolute_path = File.expand_path("app/controllers")
directory controller_absolute_path

desc "Convert ban type"
task :convert_ban_type, [:og_ban_type, :new_ban_type] => :environment do |t, args|
  og_ban_type = args.og_ban_type
  new_ban_type = args.new_ban_type
  bans = Ban.where(:ban_type => og_ban_type)
  bans.each { |ban|
    ban.ban_type = new_ban_type
    ban.save
    puts "Updated travel restriction by #{Country.find(ban.banner_id)} on #{Country.find(ban.bannee_id)} from #{og_ban_type} to #{ban.ban_type}"
  }
end