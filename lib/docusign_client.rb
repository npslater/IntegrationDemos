require 'json'
require 'rest-client'

class DocuSignClient

	attr_reader :credentials 
    private :credentials

    private

    	def initialize(credentials = {})
    		@credentials = credentials
    	end

        def authHeader
            "<DocuSignCredentials><Username>#{credentials[:username]}</Username><Password>#{credentials[:password]}</Password><IntegratorKey>#{credentials[:key]}</IntegratorKey></DocuSignCredentials>" 
        end

        def headers
            {"X-Docusign-Authentication" => authHeader, "content-type" => "application/json", "accept" => "application/json"}
        end

        def createEnvelopeRequestBody(templateId, emailOpts, recipientRoles)
            
            roles = []
            recipientRoles.each do |role|
                roles.push({"email" => role[:recipientEmail],"name" => role[:recipientName],"roleName" => role[:templateRoleName],"clientUserId" => role[:clientUserId]})
            end
            JSON.generate({
                "emailSubject" => emailOpts[:emailSubject],
                "emailBlurb" => emailOpts[:emailBlurb],
                "templateId" => templateId,
                "templateRoles" => recipientRoles,
                "status" => "sent"
            })
        end

        def createRecipientViewRequestBody(returnUrl, recipientInfo)
            JSON.generate({
                "returnUrl" => returnUrl,
                "authenticationMethod" => "email",
                "email" => recipientInfo[:email],
                "userName" => recipientInfo[:userName],
                "clientUserId" => recipientInfo[:clientUserId]
                })
        end

    public

        def login(url)
            RestClient.get(url, headers) do |response, request, result|
                if response.code == 200
                    return JSON.parse(response.body)
                else
                    raise "HTTP Error: #{response.code}"
                end
            end 
        end

        def createEnvelope(baseUrl, templateId, emailOpts = {}, recipientRoles=[])
            RestClient.post("#{baseUrl}/envelopes", createEnvelopeRequestBody(templateId, emailOpts, recipientRoles), headers) do |response, request, result|
                if response.code == 201
                    return JSON.parse(response.body)
                else
                    raise "HTTP Error: #{response.code}"
                end
            end
        end

        def recipientViewUrl(baseUrl, envelopeId, returnUrl, recipientInfo = {})
            RestClient.post("#{baseUrl}/envelopes/#{envelopeId}/views/recipient", createRecipientViewRequestBody(returnUrl, recipientInfo), headers) do |response, request, result|
                if response.code == 201
                    return JSON.parse(response.body)
                else
                    puts "ERROR: #{response.body}"
                    raise "HTTP Error: #{response.code}"
                end
            end 
        end
end