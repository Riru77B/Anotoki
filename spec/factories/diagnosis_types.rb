FactoryBot.define do
  factory :diagnosis_type do
    sequence(:key) { |n| "type#{n}" }
    sequence(:name) { |n| "タイプ#{n}" }
    description { "タイプの説明" }
    sequence(:position) { |n| n }
    primary_axis { association :diagnosis_axis, position: 1001 + DiagnosisAxis.count * 2 }
    secondary_axis { association :diagnosis_axis, position: primary_axis.position + 1 }

    trait :balanced do
      balanced { true }
      primary_axis { nil }
      secondary_axis { nil }
    end
  end
end
