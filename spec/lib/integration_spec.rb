require 'spec_helper'

describe "integration spec" do
  include SpecHelpers::IntegrationTestHelper

  it "should require auth=myauthkey in query string" do
    get "/things"
    last_response.status.should == 401
  end

  describe "GET /things" do
    it "should be 200 with correct output" do
      get "/things?auth=myauthkey"
      last_response.body.should have_tag(:h1, :text => "Things")
      [thing, thing_1, thing_2].each do |obj|
        last_response.body.should have_tag(:li, :with => {"data-id" => obj.id}, :text => obj.name)
      end
      last_response.should be_ok
    end
  end

  describe "GET /things/:id" do
    it "should be 200 with correct output" do
      get "/things/#{thing.id}?auth=myauthkey"
      last_response.body.should have_tag(:h1, :text => "Thing")
      last_response.body.should have_tag(:p, :text => /\: #{Regexp.escape thing.name}$/) do
        with_tag :strong, :text => "Name"
      end
      last_response.should be_ok
    end
  end

  describe "GET /things/new" do
    it "should be 200 with correct output" do
      get "/things/new?auth=myauthkey"
      last_response.body.should have_tag(:h1, :text => "New Thing")
      last_response.body.should have_form("/things", :post, :id => "new_thing") do
        with_tag :p, :with => {"data-field" => "name"} do
          with_tag :label, :with => {:for => "thing_name"}, :text => "Name"
          with_text_field "thing[name]"
        end
        with_submit "Create Thing"
      end
      last_response.should be_ok
    end
  end

  describe "GET /things/:id/edit" do
    it "should be 200 with correct output" do
      get "/things/#{thing.id}/edit?auth=myauthkey"
      last_response.body.should have_tag(:h1, :text => "Edit Thing")
      last_response.body.should have_form("/things/#{thing.id}", :post, 
            :id => "edit_thing_#{thing.id}", :class => "edit_thing") do
        with_hidden_field "_method", "put"
        with_tag :p, :with => {"data-field" => "name"} do
          with_tag :label, :with => {:for => "thing_name"}, :text => "Name"
          with_text_field "thing[name]", thing.name
        end
        with_submit "Update Thing"
      end
      last_response.should be_ok
    end
  end

  describe "POST /things" do
    it "should be 302 with valid input" do
      post "/things?auth=myauthkey", :thing => {:name => "foo"}
      last_response.should be_redirect
      URI.parse(last_response.location).path.should =~ /^\/things\/\d+$/
    end
    it "should be 200 with invalid input" do
      post "/things?auth=myauthkey", :thing => {:name => ""}
      last_response.body.should have_tag(:h1, :text => "New Thing")
      last_response.body.should have_tag(:p, :with => {:class => "error"}, 
           :text => "Name can't be blank")
      last_response.body.should have_form("/things", :post, :id => "new_thing")
      last_response.should be_ok
    end
  end

  describe "PUT /things/:id" do
    it "should be 302 with valid input" do
      put "/things/#{thing.id}?auth=myauthkey", :thing => {:name => "foo"}
      last_response.should be_redirect
      URI.parse(last_response.location).path.should == "/things/#{thing.id}"
      thing.name.should == "foo"
    end
    it "should be 302 with valid input (via POST and _method=put)" do
      post "/things/#{thing.id}?auth=myauthkey", :thing => {:name => "foo"}, "_method" => "put"
      last_response.should be_redirect
      URI.parse(last_response.location).path.should == "/things/#{thing.id}"
      thing.name.should == "foo"
    end
    it "should be 200 with invalid input" do
      put "/things/#{thing.id}?auth=myauthkey", :thing => {:name => ""}
      last_response.body.should have_tag(:h1, :text => "Edit Thing")
      last_response.body.should have_tag(:p, :with => {:class => "error"}, 
           :text => "Name can't be blank")
      last_response.body.should have_form("/things/#{thing.id}", :post, :id => "edit_thing_#{thing.id}")
      last_response.should be_ok
    end
  end

  describe "DELETE /things/:id" do
    it "should be 302 with valid input" do
      delete "/things/#{thing.id}?auth=myauthkey"
      last_response.should be_redirect
      URI.parse(last_response.location).path.should == "/things"
      thing.should_not be_persisted
    end
    it "should be 302 with valid input (via POST and _method=delete)" do
      post "/things/#{thing.id}?auth=myauthkey", "_method" => "delete"
      last_response.should be_redirect
      URI.parse(last_response.location).path.should == "/things"
      thing.should_not be_persisted
    end
  end
end
