require 'spec_helper'

describe "Index Page" do |variable|
	it "Should have a page header div" do
		visit "/"
		page.should have_selector("div.page-header")
	end

    it "should have a title of \"Home\"" do
        visit "/"
        page.should have_selector("title", :text => "Integration Demos | Home")
    end
end