require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post("https://slack.com/api/rtm.start", params: { token: ENV['SLACK_API_TOKEN'] })
rc = JSON.parse(response.body)
url = rc['url']

EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :open { p [:open] }

  ws.on :message do |event|
    data = JSON.parse(event.data)

    send_apology(ws, data, data['channel']) if data['text'] == ':atsumori:'
    send_apology(ws, data, data['item']['channel']) if data['reaction'] == 'atsumori'
  end

  ws.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end
end

def send_apology(ws:, data:, channel:)
  p [:message, data]
  ws.send({
    type: 'message',
    text: "失礼しました。熱盛と出てしまいました。",
    channel: channel
    }.to_json)
end
