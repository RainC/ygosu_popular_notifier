require 'net/http'
require 'nokogiri'
require "bunny"
require "dotenv/load"

def process_response(response,service_name)
    latest_url = nil
    case service_name
    when "ygosu"
        if response.status == 502
            return "http://ygosu.com^YGOSU점검중"
        else
            page = Nokogiri::HTML(response.body)
            title = page.css('.tit a')[0].text
            children = page.search('td')
            list = children.search('a')[1]
            latest_url = list.to_a[0][1] 
            return "#{latest_url}^#{title}"
        end
    end 
end

def get_response(service_name, url)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        response = http.request request # Net::HTTPResponse object
        return process_response(response,service_name) # return URL
    end
end


def sync_queue_client(queue_server, user, pass, vhost, send_payload, service_name)
    conn = Bunny.new(:host => queue_server , :user =>  user , :pass => pass , :port => "5672", :vhost => vhost)
    p "[Console] Connect to RabbitMQ Server .."
    conn.start
    ch = conn.create_channel
    q  = ch.queue(service_name)
    delivery_info, metadata, payload = q.pop 
    if send_payload == payload
        # p "current Payload : #{payload}"
    else
        p "[Console] Pushing to ygosu Subscriber"
        q.publish(send_payload) 
    end
    conn.stop
    return payload
end

def init(queue_server, user ,pass, vhost ) 
    sync_url_ygosu = get_response("ygosu", "https://www.ygosu.com/community/real_article") 
    sync_queue_client(queue_server, user, pass, vhost, sync_url_ygosu, "ygosu" )
    while true
        latest_url_ygosu = get_response("ygosu", "https://www.ygosu.com/community/real_article") 
        if (sync_url_ygosu == latest_url_ygosu ) 
            p "[Console] No changes, latest : #{latest_url_ygosu}"
        else
            sync_queue_client(queue_server, user, pass, vhost, latest_url_ygosu, "ygosu" )
            sync_url_ygosu = get_response("ygosu", "https://www.ygosu.com/community/real_article") 
        end  
        sleep 2
    end
end


init( ENV["QUEUE_SERVER"] ,ENV["QUEUE_SERVER_ID"], ENV["QUEUE_SERVER_PW"], "/push") 
