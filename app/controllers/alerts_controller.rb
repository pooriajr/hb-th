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
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://hooks.slack.com/services/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")
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
