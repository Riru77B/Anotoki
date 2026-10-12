# 診断軸（分析力・課題解決力など7つ）
class DiagnosisAxis < ApplicationRecord
  has_many :questions, dependent: :restrict_with_error
  has_many :choice_scores, dependent: :restrict_with_error
  has_many :diagnosis_scores, dependent: :restrict_with_error
  has_many :other_diagnosis_scores, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :position, presence: true, uniqueness: true
  # 結果画面に出す文章（強みTOP3・下位2つ）と、面接用に使う予定の文章
  validates :strength_scene, :growth_hint, :low_score_merit, :flip_side, presence: true
  validates :hint_study, :hint_work, :hint_club, :hint_private, presence: true
  validates :others_view, :strength_portrait, presence: true

  # 思い出しのヒント（場面の名前と文章）を表示順に返す
  RECALL_SCENES = { hint_study: "📚 勉強・ゼミ", hint_work: "💼 アルバイト", hint_club: "🎉 サークル・部活", hint_private: "👥 友人・家族" }.freeze

  def recall_hints
    RECALL_SCENES.map { |column, scene| [ scene, public_send(column) ] }
  end

  default_scope { order(:position) }
end
