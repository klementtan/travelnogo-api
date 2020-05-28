require 'net/http'
desc 'Migrating all data to server'
task :migrate_server, [:endpoint] => [:environment] do |t, args|
  all_bas = []
  Ban.all.each do |ban|
    all_bas.append(BanSerializer.new(ban).serializable_hash)
  end
  header = {'Content-Type': 'application/json'}

  uri = URI.parse(args[:endpoint])
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)
  body = {
    data: all_bas.to_json
  }
  request.body = body.to_json
  puts request.body
  response = http.request(request)

  puts 'Stratus: ' + response.status

end