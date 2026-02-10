class Relationship < ApplicationRecord
  # follower_idやfollowed_idをuserモデルのidとして扱えるようになる
  # 本来はfollower_idとfollowed_idなのですが、自動で名前を推測してくれてる
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # presence: trueにすることで空欄でDB登録することを防ぐ
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
