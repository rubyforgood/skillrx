class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :contributors
  has_many :providers, through: :contributors

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password_digest, presence: true
end
