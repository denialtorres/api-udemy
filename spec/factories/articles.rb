FactoryBot.define do
  factory :article do
    title { "Sample Article" }
    content { "Sample Content" }
    slug { "sample-article" }
  end

  sequence :slug do |n|
    "sample-article-#{n}"
  end
end
