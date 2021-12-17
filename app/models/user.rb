class User < ApplicationRecord
  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true

  has_one :access_token, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  def password
    @password ||= BCrypt::Password.new(encrypted_password)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.encrypted_password = @password
  end
end
