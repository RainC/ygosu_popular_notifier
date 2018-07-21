# ygosu_popular_notifier
- http://ygosu.rainclab.net
- 실행 중인 페이지


# 알림 받는 방법
![](https://i.imgur.com/SvZABoJ.png)

# 알림 화면 예시
![](https://i.imgur.com/mm77HH2.png)
- 클릭하면 해당 게시물로 이동

# 사용한 Library / Service
- bunny - RabbitMQ Client
- nokogiri - HTML Parser
- sinatra - Web Server
- dotenv - .env 파서
- json - JSON 파싱용
- https://onesignal.com - 푸쉬 알림 기능 

# 실행 방법
- clone
```
git clone https://github.com/RainC/ygosu_popular_notifier/
```
- gem install
```
bundle install
```
- RabbitMQ Server Environment Setting `.env`
```
QUEUE_SERVER=
QUEUE_SERVER_ID=
QUEUE_SERVER_PW=
```

- Run
```
ruby Publisher.rb
```

```
ruby NotifiytoDevice.rb
```

```
ruby WebApplicationServer.rb
```
