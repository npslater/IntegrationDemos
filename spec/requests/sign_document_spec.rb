require 'spec_helper'

describe 'Embedded signing signature request page' do |variable|
    it 'should have a hero unit' do
        visit '/demos/docusign/embedded-signing'
        page.should have_selector("div.hero-unit")
        page.should have_selector("a", :href => "/")
    end
end
