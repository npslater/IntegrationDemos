require 'docusign_client'

class DocumentSignRequestController < ApplicationController

    def upload
        client = DocuSignClient.new({:username => AppConfig.docusign['username'], :password => AppConfig.docusign['password'], :key => AppConfig.docusign['key']})
        baseUrl = client.login(AppConfig.docusign["login_url"])["loginAccounts"][0]["baseUrl"]
    end

end