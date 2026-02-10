class AccountActivationsController < ApplicationController

  # メールの内容からリンクを踏んだ時
  def edit
    user = User.find_by(email: params[:email])
    # userが存在すること
    # userのactivatedがnil or falseであること
    # DBに保存されているハッシュ化されているトークンとメールのリンクに埋め込まれているトークンが一致するか
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      # セッションの発行
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
