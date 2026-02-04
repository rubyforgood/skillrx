module FeatureFlags
  extend self

  def enabled?(flag_name, user: nil)
    override = Current.feature_overrides&.dig(flag_name.to_sym)
    return override unless override.nil?

    env_value = ENV["FEATURE_#{flag_name.to_s.upcase}"]
    return cast_boolean(env_value) unless env_value.nil?

    config = feature_config(flag_name)
    return false if config.nil?
    return cast_boolean(config) unless config.respond_to?(:dig)

    return true if cast_boolean(config[:enabled])

    user_allowed?(config, user)
  end

  def disabled?(flag_name, user: nil)
    !enabled?(flag_name, user: user)
  end

  def enable!(flag_name)
    (Current.feature_overrides ||= {})[flag_name.to_sym] = true
  end

  def disable!(flag_name)
    (Current.feature_overrides ||= {})[flag_name.to_sym] = false
  end

  def with(flag_name, value)
    old = Current.feature_overrides&.dig(flag_name.to_sym)
    value ? enable!(flag_name) : disable!(flag_name)
    yield
  ensure
    if old.nil?
      Current.feature_overrides&.delete(flag_name.to_sym)
    else
      Current.feature_overrides[flag_name.to_sym] = old
    end
  end

  private

  def feature_config(flag_name)
    Rails.application.credentials.dig(:features, flag_name.to_sym)
  end

  def user_allowed?(config, user)
    return false if user.nil?

    allowed_emails = config[:allowed_emails]
    return false if allowed_emails.blank?

    allowed_emails.include?(user.email)
  end

  def cast_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value) || false
  end
end
