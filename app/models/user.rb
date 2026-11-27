# == Schema Information
#
# Table name: users
# Database name: primary
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
  has_many :sessions, dependent: :destroy
  has_many :contributors
  has_many :providers, through: :contributors

  normalizes :email, with: ->(e) { e.strip.downcase }

  # A blank email gets one message, not "blank" and "invalid". The password's presence is checked by
  # has_secure_password (on :password, where the form shows it); checking password_digest too listed
  # "Password digest can't be blank" as well.
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  # After the email validation, so the error summary lists email then password, as the form does.
  has_secure_password
  validate :provider_must_exist

  scope :search_with_params, ->(params) do
    self
      .then { |scope| params[:email].present? ? scope.where("email ILIKE ?", "%#{params[:email]}%") : scope }
      .then { |scope| params[:is_admin].present? ? scope.where(is_admin: params[:is_admin]) : scope }
      .then { |scope| scope.order(created_at: params[:order]&.to_sym || :desc) }
  end

  def provider_must_exist
    return if providers.any?
    return if is_admin

    errors.add(:provider_ids, :none_chosen)
  end
end
