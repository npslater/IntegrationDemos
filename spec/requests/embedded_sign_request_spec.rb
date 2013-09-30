require 'spec_helper'

describe 'EmbeddedSignRequest pages' do |variable|
    
    describe "new request page" do
        it "should have the correct header" do
                visit "/demos/docusign/embedded-signing/new" 
                page.should have_selector("h2", text: 'Create an Embedded Sign Request')
        end
    end
end