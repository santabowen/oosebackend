# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/forget_password_confirmation
  def forget_password_confirmation
    UserMailer.forget_password_confirmation
  end

end
