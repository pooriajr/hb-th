require 'net/http'
require 'uri'
require 'json'

class AlertsController < ApplicationController
  def create
    @payload = JSON.parse(request.body.read)
    alert_slack if spam_notification?
    render :json => { :status => "ok" }
  end

  private
  
  def spam_notification?
    @payload["Type"] == "SpamNotification"
  end
  
  def alert_slack
    uri = URI.parse Rails.application.credentials.slack_webhook_url
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = JSON.dump({
      "text" => "Spam notification re: #{@payload["Email"]}",
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
