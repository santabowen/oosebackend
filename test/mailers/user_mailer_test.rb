require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "forget_password_confirmation" do
    mail = UserMailer.forget_password_confirmation
    assert_equal "Forget password confirmation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
