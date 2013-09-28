require 'spec_helper'

describe DocuSignClient do |variable|

	let!(:credentials) { {:username => AppConfig.docusign['username'], :password => AppConfig.docusign['password'], :key => AppConfig.docusign['key'] } }
	
	let!(:client) { DocuSignClient.new(credentials) }
	let!(:loginUrl) { AppConfig.docusign['login_url'] }

	let(:baseUrl) {
		DocuSignClient.new(credentials).login(loginUrl)["loginAccounts"][0]["baseUrl"]
	}

	let(:roles) {
		[
			{
				:email => AppConfig.docusign["recipientEmail"],
				:name => AppConfig.docusign["recipientName"],
				:roleName => AppConfig.docusign["templateRoleName"],
				:clientUserId => '1001'
			}
		]
	}

	let(:templateId) { AppConfig.docusign["templateId"] }

	let(:emailOpts) { 
		{
			:emailSubject =>'Docusign API calls - Programmatic Sending', 
			:emailBlurb => 'This was sent using the REST API in a ruby program'
		}
	}

	let(:envelopeId) {
		client.createEnvelope(baseUrl, templateId, emailOpts, roles)["envelopeId"]
	}

	let(:returnUrl) { "http://localhost:3000/docusign/finish" }

    let(:recipientInfo) {
        {
            :email => AppConfig.docusign["recipientEmail"],
            :userName => AppConfig.docusign["recipientName"],
            :clientUserId => '1001'
        }
    }

	it "should have a constructor that takes a hash of credentials and returns an instance" do
		#puts "config: #{AppConfig.docusign}"
		client.should be_an_instance_of(DocuSignClient)
	end

	it "should return a hash on successful login" do
		client.login(AppConfig.docusign['login_url']).should be_an_instance_of(Hash)
	end

	it "should have a baseUrl property in the hash returned from successful login" do
		baseUrl = client.login(loginUrl)["loginAccounts"][0]["baseUrl"]
		baseUrl.should_not be_nil
	end

	it "should return a hash on successful envelope creation" do
		client.createEnvelope(baseUrl, templateId, emailOpts, roles).should be_an_instance_of(Hash)
	end

	it "should have a envelopeId property in the hash returned from successful envelope creation" do
		envelopeId = client.createEnvelope(baseUrl, templateId, emailOpts, roles)["envelopeId"]
		envelopeId.should_not be_nil
	end

	it "should return a URL to the recipient view for the envelope Id returned from envelope creation" do
		client.recipientViewUrl(baseUrl, envelopeId, returnUrl, recipientInfo).should_not be_nil
	end
end