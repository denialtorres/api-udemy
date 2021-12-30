# frozen_string_literal: true

class AccessTokenSerializer
  include JSONAPI::Serializer
  attributes :id, :token
end
