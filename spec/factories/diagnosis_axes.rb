FactoryBot.define do
  factory :diagnosis_axis do
    sequence(:key) { |n| "axis#{n}" }
    sequence(:name) { |n| "診断軸#{n}" }
    description { "診断軸の説明" }
    sequence(:position) { |n| n }
  end
end
