class UserMailer < ApplicationMailer
  # default from: "from@example.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.forget_password_confirmation.subject
  #
  def forget_password_confirmation(user)
    @user_name = user.name
    @user_validation = user.validation_code
    # mail to: "user.email", subject: "forget Password Confirmation"
    mail(to: user.email, subject: "forget Password Confirmation")
  end
end
