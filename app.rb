require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  BW_CLIENT_ID = ENV.fetch('BW_CLIENT_ID')
  BW_CLIENT_SECRET = ENV.fetch('BW_CLIENT_SECRET')
  LOCAL_PORT = Integer(ENV.fetch('LOCAL_PORT'))
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT
set :host_authorization, permitted_hosts: []

Bandwidth.configure do |config|
  config.client_id = BW_CLIENT_ID
  config.client_secret = BW_CLIENT_SECRET
  config.return_binary_data = true
end

def parse_callback(expected_event_type)
  data = JSON.parse(request.body.read)
  halt 400 unless data.is_a?(Hash) && data['eventType'] == expected_event_type
  data
rescue JSON::ParserError
  halt 400
end

post '/callbacks/inbound/voice' do
  parse_callback('initiate')

  unavailable_speak_sentence = Bandwidth::Bxml::SpeakSentence.new('You have reached Vandelay Industries, Kal Varnsen is unavailable at this time.')
  message_speak_sentence = Bandwidth::Bxml::SpeakSentence.new('At the tone, please record your message, when you have finished recording, you may hang up.')
  play_audio = Bandwidth::Bxml::PlayAudio.new('/tone.mp3')
  record = Bandwidth::Bxml::Record.new({ recording_available_url: '/callbacks/inbound/voice/recordingAvailable', max_duration: 30 })
  bxml = Bandwidth::Bxml::Response.new([unavailable_speak_sentence, message_speak_sentence, play_audio, record])

  content_type 'application/xml'
  bxml.to_bxml
end

get '/tone.mp3' do
  send_file 'tone.mp3', type: 'audio/mpeg'
end

post '/callbacks/inbound/voice/recordingAvailable' do
  data = parse_callback('recordingAvailable')

  begin
    recording = Bandwidth::RecordingsApi.new.download_call_recording(BW_ACCOUNT_ID, data['callId'], data['recordingId'])

    File.open("#{data['recordingId']}.#{data['fileFormat']}", 'wb') do |file|
      file.write(recording)
    end
  rescue StandardError => e
    warn "Failed to download recording: #{e.message}"
    halt 500
  end

  status 204
end
