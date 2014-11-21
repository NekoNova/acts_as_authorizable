FactoryGirl.define do
  factory :forum_membership do
    association :user, factory: :user
    association :forum, factory: :forum
    association :role, factory: :role
  end
end