require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']
  })

rc = JSON.parse(response.body)

url = rc['url']

EM.run do
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)

  #  接続が確立した時の処理
  ws.on :open do
    p [:open]
  end

  # RTM APIから情報を受け取った時の処理
  ws.on :message do |event|
    data = JSON.parse(event.data)

    if data['text'] == ':atsumori:'
      ws.send({
        type: 'message',
        text: "失礼しました。熱盛と出てしまいました。",
        channel: data['channel']
        }.to_json)
    end

    if data['reaction'] == 'atsumori'
      ws.send({
        type: 'message',
        text: "失礼しました。熱盛と出てしまいました。",
        channel: data['item']['channel']
        }.to_json)
    end
  end

  # 接続が切断した時の処理
  ws.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end
end
