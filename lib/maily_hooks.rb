if defined?(Maily)
  user = ""

  Maily.hooks_for("PasswordsMailer") do |mailer|
    mailer.register_hook(:reset, user)
  end
end
