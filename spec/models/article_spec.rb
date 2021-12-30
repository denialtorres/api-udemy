# frozen_string_literal: true

require "rails_helper"

RSpec.describe Article, type: :model do
  describe "#validations" do
    let(:article) { create(:article) }
    let(:article_two) { build(:article, slug: article.slug) }

    it "test that a factory is valid" do
      expect(article).to be_valid # article.valid? == true
    end

    it "has an invalid title" do
      article.title = ""
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it "has an invalid content" do
      article.content = ""
      expect(article).not_to be_valid
      expect(article.errors[:content]).to include("can't be blank")
    end

    it "has an invalid slug" do
      article.slug = ""
      expect(article).not_to be_valid
      expect(article.errors[:slug]).to include("can't be blank")
    end

    it "validates uniqueness of the slug" do
      expect(article_two).not_to be_valid
      expect(article_two.errors[:slug]).to include("has already been taken")

      ## generate another slug
      article_two.slug = generate(:slug)
      expect(article_two).to be_valid
    end
  end

  describe ".recent" do
    it "returns articles correct order" do
      older_article = create(:article,
                             created_at: 1.hour.ago)
      recent_article = create(:article, slug: generate(:slug))

      expect(described_class.recent).to eq(
        [recent_article, older_article]
      )

      recent_article.update_column(:created_at, 2.hours.ago)
      expect(described_class.recent).to eq(
        [older_article, recent_article]
      )
    end
  end
end
