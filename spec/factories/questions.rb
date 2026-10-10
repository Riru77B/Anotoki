FactoryBot.define do
  factory :question do
    diagnosis_axis
    sequence(:content) { |n| "質問#{n}" }
    sequence(:other_content) { |n| "他者向けの質問#{n}" }
    sequence(:position) { |n| n }
  end
end
