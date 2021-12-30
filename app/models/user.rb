# frozen_string_literal: true

class User < ApplicationRecord
  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :password, presence: true, if: -> { provider == "standard" }

  has_one :access_token, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  def password
    @password ||= BCrypt::Password.new(encrypted_password) if encrypted_password.present?
  rescue BCrypt::Errors::InvalidHash
    encrypted = BCrypt::Password.create(encrypted_password)
    @password ||= BCrypt::Password.new(encrypted) if encrypted_password.present?
  end

  def password=(new_password)
    # rubocop:disable Lint/ReturnInVoidContext
    return @password = new_password if new_password.blank?
    # rubocop:enable Lint/ReturnInVoidContext

    @password = BCrypt::Password.create(new_password)
    self.encrypted_password = @password
  end
end
