class ApplicationController < ActionController::Base
  # コントローラー内であればsessionhelperに定義されたメソッドを呼び出せる
  include SessionsHelper

  private

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end
end
