require 'spec_helper'

describe "Index Page" do |variable|
	it "Should have a hero unit div" do
		visit "/"
		page.should have_selector("div.hero-unit")
	end

    it "should have a title of \"Home\"" do
        visit "/"
        page.should have_selector("title", :text => "Integration Demos | Home")
    end
end