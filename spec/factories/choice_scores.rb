FactoryBot.define do
  factory :choice_score do
    choice
    diagnosis_axis
    score { 3 }
  end
end
