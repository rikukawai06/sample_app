class ApplicationController < ActionController::Base
  # コントローラー内であればsessionhelperに定義されたメソッドを呼び出せる
  include SessionsHelper

  # rubyのprivateは子クラスから参照できる
  # application_controller.rbを継承しているものであれば参照可能
  private

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        # 開こうとしていたページのURLを保存
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end
end
