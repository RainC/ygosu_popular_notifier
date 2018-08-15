# encoding: UTF-8

require "bunny"
require 'net/http'
require "json"
require "dotenv/load"
def go_push(url,title)
    params = {"app_id" => "4b03f8b6-3416-4cc3-91f8-96e4df4ee5e8", 
    "title" => "와이고수 실인게 알림",
    "contents" => {"en" => title.force_encoding(Encoding::UTF_8)},
    "included_segments" => ["All"],
    "url" => url} 
    p
    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    request = Net::HTTP::Post.new(uri.path,
                                'Content-Type'  => 'application/json;charset=utf-8',
                                'Authorization' => "Basic Yzc4NTRlN2ItMWY1Mi00OWE1LTkwYWQtNDgzMjc5ZmY0NWI0")
    request.body = params.to_json
    response = http.request(request) 
    puts response.body
end

def sync_queue_client(queue_server, user, pass, vhost, service_name) 
    conn = Bunny.new(:host => queue_server , :user =>  user , :pass => pass , :port => "5672", :vhost => vhost)
    p "[Console] Connect to RabbitMQ Server .."
    conn.start
    ch = conn.create_channel
    q  = ch.queue(service_name)
    while true 
        p "[Console] Connected"
        delivery_info, metadata, payload = q.pop 
        if payload
            url = payload.split("^")[0]
            title = payload.split("^")[1]
            go_push(url,title)
        else
            p "[Console] No Payload"
        end 
        sleep 2
    end 
    conn.stop  
end
 
sync_queue_client( ENV["QUEUE_SERVER"] ,ENV["QUEUE_SERVER_ID"], ENV["QUEUE_SERVER_PW"], "/", "ygosu" ) 
 
