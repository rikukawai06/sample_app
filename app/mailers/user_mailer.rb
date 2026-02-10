class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
    debugger
    # debuggerをここに打ってmail.text_part.body.decodedをコンソール上で入力すればmailの中身を確認できる
  end

  def password_reset(user)
    
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
