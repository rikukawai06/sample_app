class User < ApplicationRecord
  # micropostsモデルのuser_idを探しに行く
  has_many :microposts, dependent: :destroy
  # relationshipsテーブル内のfollower_idが一対多なのでそれを明示的に示している
  has_many :active_relationships, class_name: "Relationship", 
                                  foreign_key: "follower_id", 
                                  dependent: :destroy
  
  # active_relationshipsを経由してfollowedsのレコードを取得できるようになる設定。
  # 本来user.active_relationships.followedsとするところをuser.followedsと短略することができる。
  # sourceは名前付け、followedという実際の名前をfollowingとして扱う
  has_many :following, through: :active_relationships, source: :followed

  # relationshipsテーブル内のfollowed_idが一対多なのでそれを明示的に示している
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest
  before_save { self.email = email.downcase }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  def authenticated?(attribute, token)
    # sendを使って動的に「activation_digest」や「remember_digest」を呼び出す
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
    
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    # ids = following_ids << id
    # Micropost.where("user_id IN (?)", ids)
    

    # DBに問い合わせてるわけではなくてクエリ文の文字列を保存している
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"

    
    # 先ほどの文字列を式展開してサブクエリとして挿入
    # .includesをつけているのはN+1問題が発生してしまうのを防ぐため
    # :userは投稿したユーザーの情報を取得
    # image_attachment: :blobは画像データがあるなら画像データを取得する
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
             .includes(:user, image_attachment: :blob)
  end

  # ユーザーをフォローする
  def follow(other_user)
    # other_userが自分自身でない時にfollowing(followed_id)にuser_idを追加する
    following << other_user unless self == other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    following.delete(other_user)
  end

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  private
    # メールアドレスをすべて小文字にする
    def downcase_email
      email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
