require 'rails_helper'

RSpec.describe Article, type: :model do
  describe '#validations' do
    let(:article) { create(:article) }
    let(:article_two) { build(:article) }

    it 'test that a factory is valid' do
      expect(article).to be_valid # article.valid? == true
    end

    it 'has an invalid title' do
      article.title = ''
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it 'has an invalid content' do
      article.content = ''
      expect(article).not_to be_valid
      expect(article.errors[:content]).to include("can't be blank")
    end

    it 'has an invalid slug' do
      article.slug = ''
      expect(article).not_to be_valid
      expect(article.errors[:slug]).to include("can't be blank")
    end

    it 'validates uniqueness of the slug' do
      article_two.slug = article.slug
      expect(article_two).not_to be_valid
      expect(article_two.errors[:slug]).to include("has already been taken")

      ## generate another slug
      article_two.slug = generate(:slug)
      expect(article_two).to be_valid
    end
  end
end
