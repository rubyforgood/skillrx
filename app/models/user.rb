# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  is_admin        :boolean          default(FALSE), not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :contributors
  has_many :providers, through: :contributors

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password_digest, presence: true

  scope :search_with_params, ->(params) do
    self
      .then { |scope| params[:email].present? ? scope.where("email ILIKE ?", "%#{params[:email]}%") : scope }
      .then { |scope| params[:is_admin].present? ? scope.where(is_admin: params[:is_admin]) : scope }
      .then { |scope| scope.order(created_at: params[:order]&.to_sym || :desc) }
  end

  def topics
    Topic.where(provider_id: providers.pluck(:id))
  end
end
