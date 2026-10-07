class User < ApplicationRecord
  # パスワード再設定（:recoverable）はメール送信の準備ができてから追加する
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  has_many :diagnoses, dependent: :destroy

  validates :name, presence: true, length: { maximum: 30 }
end
