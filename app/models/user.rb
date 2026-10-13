class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :diagnoses, dependent: :destroy
  has_one :diagnosis_invitation, dependent: :destroy

  validates :name, presence: true, length: { maximum: 30 }
end
