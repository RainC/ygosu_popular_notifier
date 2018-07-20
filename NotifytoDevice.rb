require 'amqp'
EventMachine.run do
    connection = AMQP.connect(:host => ENV["QUEUE_SERVER"] , :user =>  ENV["QUEUE_SERVER_ID"] , :pass => ENV["QUEUE_SERVER_PW"] )
    puts "Connecting to RabbitMQ. Running #{AMQP::VERSION} version of the gem..." 
    ch  = AMQP::Channel.new(connection)
    q   = ch.queue("ygosu" )
    x   = ch.default_exchange

    q.subscribe do |metadata, payload|
        p "Sent to Device - #{payload}"
        params = {"app_id" => "5eb5a37e-b458-11e3-ac11-000c2940e62c", 
          "contents" => {"en" => payload},
          "included_segments" => ["All"]}
        uri = URI.parse('https://onesignal.com/api/v1/notifications')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path,
                                    'Content-Type'  => 'application/json;charset=utf-8',
                                    'Authorization' => "Basic NGEwMGZmMjItY2NkNy0xMWUzLTk5ZDUtMDAwYzI5NDBlNjJj")
        request.body = params.as_json.to_json
        response = http.request(request) 
        puts response.body
    end 
end