require 'net/http'
desc 'Migrating all data to server'
task :migrate_server, [:endpoint] => [:environment] do |t, args|
  all_bans = []
  Ban.all.each do |ban|
    all_bans.append(BanSerializer.new(ban).serializable_hash)
  end
  header = {'Content-Type': 'application/json'}

  count = 0
  while count < all_bans.length
    curr_count = 0
    curr_bans = []
    while curr_count < 100 &&  count < all_bans.length
      ban = all_bans[count]
      curr_bans.append(ban)
      curr_count+=1
      count+=1
    end
    puts 'Sending chunk ' + count.to_s

    uri = URI.parse(args[:endpoint])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    sleep 3
    body = {
        data: curr_bans.to_json
    }
    request.body = body.to_json
    response = http.request(request)
    puts 'Status: ' + response.code
    puts 'Message: ' + response.message


  end
end