# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    content { "My Comment" }
    association :article
    association :user
  end
end
