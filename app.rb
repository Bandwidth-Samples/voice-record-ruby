require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_USERNAME = ENV.fetch('BW_USERNAME')
  BW_PASSWORD = ENV.fetch('BW_PASSWORD')
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  LOCAL_PORT = ENV.fetch('LOCAL_PORT')
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT

Bandwidth.configure do |config| # Configure Basic Auth
  config.username = BW_USERNAME
  config.password = BW_PASSWORD
  config.return_binary_data = true
end

post '/callbacks/callInitiatedCallback' do
  unavailable_speak_sentence = Bandwidth::Bxml::SpeakSentence.new('You have reached Vandelay Industries, Kal Varnsen is unavailable at this time.')
  message_speak_sentence = Bandwidth::Bxml::SpeakSentence.new('At the tone, please record your message, when you have finished recording, you may hang up.')
  play_audio = Bandwidth::Bxml::PlayAudio.new('Tone.mp3')
  record = Bandwidth::Bxml::Record.new({ recording_available_url: '/callbacks/recordingAvailableCallback' })
  response = Bandwidth::Bxml::Response.new([unavailable_speak_sentence, message_speak_sentence, play_audio, record])

  return response.to_bxml
end

get '/callbacks/Tone.mp3' do
  response.headers['Content-Type'] = 'audio/mp3'

  tone_file = File.open('Tone.mp3')
  file_data = tone_file.read
  tone_file.close
  file_data
end

post '/callbacks/recordingAvailableCallback' do
  data = JSON.parse(request.body.read)

  if data['eventType'] == 'recordingAvailable'
    recordings_api = Bandwidth::RecordingsApi.new

    file_format = data['fileFormat']
    call_id = data['callId']
    recording_id = data['recordingId']

    recording = recordings_api.download_call_recording(BW_ACCOUNT_ID, call_id, recording_id)

    File.open("#{recording_id}.#{file_format}", 'wb') do |file|
      file.write(recording)
    end
  end
end
