FactoryGirl.define do
  factory :role do
    name 'Forum Moderator'
    permissions 'moderate, view'
  end
end