require 'docusign_client'
require 'json'

class SignDocumentController < ApplicationController

	def embeddedSigning
        client = DocuSignClient.new({:username => AppConfig.docusign['username'], :password => AppConfig.docusign['password'], :key => AppConfig.docusign['key']})
        baseUrl = client.login(AppConfig.docusign["login_url"])["loginAccounts"][0]["baseUrl"]
        envelopeId = client.createEnvelope(baseUrl, 
            AppConfig.docusign["templateId"],
            {
                :emailSubject => "Integration Demos: Embedded Signing with DocuSign",
                :emailBlurb => "This signing request was created from within the Integration Demos: Embedded Signing app"    
            },
            [
                {
                    :email => AppConfig.docusign["recipientEmail"],
                    :name => AppConfig.docusign["recipientName"],
                    :roleName => AppConfig.docusign["templateRoleName"],
                    :clientUserId => '1001'
                }
            ])["envelopeId"]
        @recipientViewUrl = client.recipientViewUrl(baseUrl, envelopeId, AppConfig.docusign["return_url"], 
            {
                :email => AppConfig.docusign["recipientEmail"],
                :userName => AppConfig.docusign["recipientName"],
                :clientUserId => '1001'
            }
        )["url"]
        render "embedded-signing"
    end

    def finish
        logger.debug "Environment var: #{ENV['Docusign.username']}"
		logger.debug AppConfig.docusign
	end
end