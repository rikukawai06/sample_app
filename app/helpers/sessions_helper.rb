module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    user.remember
    # IDの暗号化／CookieにIDを登録
    cookies.permanent.encrypted[:user_id] = user.id
    # Cookieにトークンを登録
    cookies.permanent[:remember_token] = user.remember_token
  end

  # ログイン中のユーザーを取得
  # 一時セッションか永続トークンどちらかを持っているかつそれらが正しいものなのかを判断してログインしているかいないか判断んしている
  def current_user
    # 一時セッションに保存されているuser_idとログイン中のuser_idを比較
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      # session内のidがDB内に存在するか？
      # セッション内にトークンが存在するか？
      # session内のトークンとDB内のトークンが存在するかつ一致するか？
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    # 永続トークンでのログイン認証
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    # 永続セッションの破棄
    forget(current_user) if logged_in?
    # 一時セッションの破棄
    reset_session
    # メモリ内のデータも破棄
    @current_user = nil
  end

  # アクセスしようとしたURLを保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
