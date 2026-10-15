FactoryBot.define do
  factory :choice do
    question
    sequence(:content) { |n| "選択肢#{n}" }
    sequence(:position) { |n| n }
  end
end
