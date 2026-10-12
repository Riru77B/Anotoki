FactoryBot.define do
  factory :diagnosis_axis do
    sequence(:key) { |n| "axis#{n}" }
    sequence(:name) { |n| "診断軸#{n}" }
    description { "診断軸の説明" }
    sequence(:position) { |n| n }
    strength_scene { "強みとして働く場面" }
    growth_hint { "もっと活かすヒント" }
    low_score_merit { "低めのときの良さ" }
    flip_side { "裏目に出る可能性" }
    hint_study { "勉強・ゼミのヒント" }
    hint_work { "アルバイトのヒント" }
    hint_club { "サークル・部活のヒント" }
    hint_private { "友人・家族のヒント" }
    others_view { "周りから見たあなた" }
  end
end
