# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/articles routes" do
  let(:article) { create(:article) }

  it "routes to articles#index" do
    aggregate_failures do
      expect(get("/articles")).to route_to("articles#index")
      expect(get("/articles?page[number]=3")).to route_to("articles#index", page: { "number" => "3" })
    end
  end

  it "routes to articles#show" do
    expect(get("articles/#{article.id}")).to route_to("articles#show", id: article.id.to_s)
  end

  it "should route to articles created" do
    expect(post("/articles")).to route_to("articles#create")
  end

  it "should route to articles update" do
    expect(put("articles/#{article.id}")).to route_to("articles#update", id: article.id.to_s)
    expect(patch("articles/#{article.id}")).to route_to("articles#update", id: article.id.to_s)
  end

  it "should reoute to articles delete" do
    expect(delete("articles/#{article.id}")).to route_to("articles#destroy", id: article.id.to_s)
  end
end
