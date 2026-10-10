# 他者診断の依頼用 URL。token は推測されにくいランダムな文字列（24文字）
class DiagnosisInvitation < ApplicationRecord
  belongs_to :user

  has_secure_token :token

  validates :user_id, uniqueness: true
end
