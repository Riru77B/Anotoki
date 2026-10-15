FactoryBot.define do
  factory :other_diagnosis_score do
    other_diagnosis
    diagnosis_axis
    raw_score { 20 }
    score { 50 }
  end
end
