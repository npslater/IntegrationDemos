require 'json'
require 'rest-client'
require 'net/http/post/multipart'

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

        def headers_multipart
          {"X-Docusign-Authentication" => authHeader, "content-type" => "multipart/form-data"}
        end

        def initialize_net_http_ssl(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          # Explicitly verifies that the certificate matches the domain. Requires
          # that we use www when calling the production DocuSign API
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          http
        end

        def init_multipart_post_request(uri, payload)
          request = Net::HTTP::Post::Multipart.new(uri.request_uri, payload, headers)
          request.body = request.body_stream.read
          puts request.body
          request
        end

        def createEnvelopeRequestBody(templateId, emailOpts, signers)
            
            roles = []
            signers.each do |signer|
                roles.push({"email" => signer[:email],"name" => signer[:name],"roleName" => signer[:role],"clientUserId" => signer[:email]})
            end
            JSON.generate({
                "emailSubject" => emailOpts[:emailSubject],
                "emailBlurb" => emailOpts[:emailBlurb],
                "templateId" => templateId,
                "templateRoles" => roles,
                "status" => "sent"
            })
        end

        def createRecipientViewRequestBody(returnUrl, signer)
            JSON.generate({
                "returnUrl" => returnUrl,
                "authenticationMethod" => "email",
                "email" => signer[:email],
                "userName" => signer[:name],
                "clientUserId" => signer[:email]
                })
        end

        def create_document_signature_payload(emailSubject, signers, documents)
          { :body => UploadIO.new(StringIO.new(JSON.generate(createDocumentSignatureBody(emailSubject, signers, documents))), "application/json", "body.json", "Content-Disposition" => "form-data")}.merge!(create_upload_ios(documents))
          #{:body => JSON.generate(createDocumentSignatureBody(emailSubject, signers, documents))}.merge!(create_upload_ios(documents))
        end

        def createDocumentSignatureBody(emailSubject, signers, documents)
            body = {
                :recipients => {
                    :signers => []
                },
                :documents => [],
                :status => 'sent',
                :emailSubject => emailSubject
            }
            signers.each_with_index do | signer, index|
                s = {
                        :email => signer[:email],
                        :name => signer[:name],
                        :recipientId => "#{index+1}",
                        :tabs => {
                            :signHereTabs => []
                    }
                }
                signer[:tabs].each do | tab |
                    s[:tabs][:signHereTabs].push({
                            :xPosition => tab[:xPosition],
                            :yPosition => tab[:yPosition],
                            :documentId => tab[:documentIndex] ? tab[:documentIndex] + 1 : 1,
                            :pageNumber => tab[:pageNumber]
                        })
                end
                body[:recipients][:signers].push(s)
            end
            documents.each_with_index do | doc, index|
                body[:documents].push({
                        :name => File.basename(doc[:path]),
                        :documentId => "#{index+1}"
                    })
            end
            body
        end

        def create_upload_ios(documents)
          ios = {}
          documents.each_with_index do | doc, index |
            ios.merge!({ "file#{index+1}" => UploadIO.new(doc[:path], doc[:content_type], File.basename(doc[:path]),"Content-Disposition" => "file; documentId=#{index+1}")})
          end
          ios
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

        def createEnvelope(baseUrl, templateId, emailOpts = {}, signers=[])
            RestClient.post("#{baseUrl}/envelopes", createEnvelopeRequestBody(templateId, emailOpts, signers), headers) do |response, request, result|
                if response.code == 201
                    return JSON.parse(response.body)
                else
                    raise "HTTP Error: #{response.code}"
                end
            end
        end

        def recipientViewUrl(baseUrl, envelopeId, returnUrl, signer = {})
            RestClient.post("#{baseUrl}/envelopes/#{envelopeId}/views/recipient", createRecipientViewRequestBody(returnUrl, signer), headers) do |response, request, result|
                if response.code == 201
                    return JSON.parse(response.body)
                else
                    puts "ERROR: #{response.body}"
                    raise "HTTP Error: #{response.code}"
                end
            end 
        end

        def requestDocumentSignature(baseUrl, emailSubject, signers = [], documents = [])
            uri = URI.parse("#{baseUrl}/envelopes")
            http = initialize_net_http_ssl(uri)
            payload = create_document_signature_payload(emailSubject, signers, documents)
            puts payload
            request = init_multipart_post_request(uri, payload)
            response = http.request(request)
            puts response.body
        end
end