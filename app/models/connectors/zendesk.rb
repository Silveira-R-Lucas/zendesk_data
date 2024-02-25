module Connectors
  class Zendesk
    require 'zendesk_api'
    def initialize
      @zendesk_system = System.find(1)
      @client = ZendeskAPI::Client.new do |config|
        config.url = @zendesk_system.url
        config.username = @zendesk_system.username
        config.token = @zendesk_system.token
        config.retry = true
      end
    end

    def get(search)
      response = @client.connection.get("/api/v2/#{search}").body
    end
  end
end