FactoryBot.define do
  factory :other_diagnosis do
    diagnosis_invitation
    status { :in_progress }

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end
  end
end
