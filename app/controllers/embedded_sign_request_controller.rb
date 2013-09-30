require 'docusign_client'
require 'json'

class EmbeddedSignRequestController < ApplicationController

    def new
        @request = EmbeddedSignRequest.new({:name => "", :email => ""})
    end

    def create
        @request = EmbeddedSignRequest.new(params)
        if !@request.valid?
            render "new"
            return
        end
        puts "Params are: #{params}"
        client = DocuSignClient.new({:username => AppConfig.docusign['username'], :password => AppConfig.docusign['password'], :key => AppConfig.docusign['key']})
        baseUrl = client.login(AppConfig.docusign["login_url"])["loginAccounts"][0]["baseUrl"]
        puts "baseUrl: #{baseUrl}"
        envelopeId = client.createEnvelope(baseUrl, 
            AppConfig.docusign["templateId"],
            {
                :emailSubject => "Integration Demos: Embedded Signing with DocuSign",
                :emailBlurb => "This signing request was created from within the Integration Demos: Embedded Signing app"    
            },
            [
                {
                    :email => params[:email],
                    :name => params[:name],
                    :roleName => AppConfig.docusign["templateRoleName"],
                    :clientUserId => '1001'
                }
            ])["envelopeId"]
        puts "envelopeId: #{envelopeId}"
        puts "params['email'] = #{params['email']}"
        puts "params['name'] = #{params['name']}"
        puts "Return URL #{AppConfig.docusign['return_url']}"
        recipientViewUrl = client.recipientViewUrl(baseUrl, envelopeId, AppConfig.docusign["return_url"], 
            {
                :email => params[:email],
                :userName => params[:name],
                :clientUserId => '1001'
            }
        )["url"]
        redirect_to recipientViewUrl
    end

    def finish
        logger.debug "Environment var: #{ENV['Docusign.username']}"
        logger.debug AppConfig.docusign
    end

end