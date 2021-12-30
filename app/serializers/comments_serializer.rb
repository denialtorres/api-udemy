# frozen_string_literal: true

class CommentsSerializer
  include JSONAPI::Serializer
  # set_type :articles
  attributes :content
  has_one :article
  has_one :user
end
