FactoryBot.define do
  factory :article do
    title { 'Sample Article' }
    content { 'Sample Content' }
    sequence(:slug) { |n| "sample-article-#{n}" }
    association :user
  end

  sequence :slug do |n|
    "sample-article-#{n}"
  end

  sequence :title do |n|
    "Super Title#{n}"
  end
end
