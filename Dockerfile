FROM ruby
ARG target_server
ARG server_id
ARG server_pw
RUN mkdir -p /data
WORKDIR /data
RUN git clone https://github.com/RainC/ygosu_popular_notifier
WORKDIR /data/ygosu_popular_notifier
RUN bundle install
RUN echo "QUEUE_SERVER=$target_server" > .env
RUN echo "QUEUE_SERVER_ID=$server_id" >> .env
RUN echo "QUEUE_SERVER_PW=$server_pw" >> .env
CMD ruby Publisher.rb & ruby NotifytoDevice.rb & ruby WebApplicationServer.rb
EXPOSE 4567
