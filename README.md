# Voice Record

<a href="https://dev.bandwidth.com/docs/voice/quickStart">
  <img src="./icon-voice.svg" title="Voice Quick Start Guide" alt="Voice Quick Start Guide"/>
</a>

 # Table of Contents

* [Description](#description)
* [Pre-Requisites](#pre-requisites)
* [Running the Application](#running-the-application)
* [Environmental Variables](#environmental-variables)
* [Callback URLs](#callback-urls)
  * [Ngrok](#ngrok)
# Description

This sample app demonstrates how to record a message from an inbound call, similar to how a voicemail machine would work.

When the user calls the Bandwidth phone number associated with this application, the user will hear an audio prompt to leave a message, then a beep. Once this happens, the call will begin recording.

When the call ends, Bandwidth will start to process the recording. Once this processing is complete, Bandwidth will send a webhook to the /recordingAvailableCallback endpoint on this application. Once received, the application will download the recording via Bandwidth's voice recording API.

# Pre-Requisites

In order to use the Bandwidth API users need to set up the appropriate application at the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and create API tokens.

To create an application log into the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and navigate to the `Applications` tab.  Fill out the **New Application** form selecting the service (Messaging or Voice) that the application will be used for.  All Bandwidth services require publicly accessible Callback URLs, for more information on how to set one up see [Callback URLs](#callback-urls).

For more information about API credentials see our [Account Credentials](https://dev.bandwidth.com/docs/account/credentials) page.

# Running the Application

To install the required packages for this app, run the command:

```sh
bundle install
```

Use the following command to run the application:

```sh
ruby app.rb
```

# Environmental Variables

The sample app uses the below environmental variables.

```sh
BW_ACCOUNT_ID                        # Your Bandwidth Account Id
BW_USERNAME                          # Your Bandwidth API Username
BW_PASSWORD                          # Your Bandwidth API Password
LOCAL_PORT                           # The port number you wish to run the sample on
```

# Callback URLs

For a detailed introduction, check out our [Bandwidth Product Specific Callbacks](https://dev.bandwidth.com/docs/voice/webhooks) page.

Below are the callback paths:
* `/callbacks/callInitiatedCallback`
* `/callbacks/recordingAvailableCallback`

## Ngrok

A simple way to set up a local callback URL for testing is to use the free tool [ngrok](https://ngrok.com/).  
After you have downloaded and installed `ngrok` run the following command to open a public tunnel to your port (`$LOCAL_PORT`)

```sh
ngrok http $LOCAL_PORT
```

You can view your public URL at `http://127.0.0.1:4040` after ngrok is running.  You can also view the status of the tunnel and requests/responses here. Once your public ngrok url has been created, you can use it as the `BASE_CALLBACK_URL` environmental variable and set it in the voice application created in the [Pre-Requisites](#pre-requisites) section.
