require 'google/api_client'

class GoogleClient

  private

    def scopes
      [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile'
      ]
    end

    def client_id
      AppConfig.google['client_id']
    end

    def client_secret
      AppConfig.google['client_secret']
    end

    def redirect_url
      AppConfig.google['redirect_url']
    end

  public

    def get_authorization_uri(email_address, state)
      client = Google::APIClient.new
      client.authorization.client_id = client_id
      client.authorization.redirect_uri = redirect_url
      client.authorization.scope = scopes

      uri  = client.authorization.authorization_uri
      return uri.to_s
    end

end