FactoryBot.define do
  factory :diagnosis_score do
    diagnosis
    diagnosis_axis
    raw_score { 20 }
    score { 50 }
  end
end
