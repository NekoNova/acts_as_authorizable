class ForumMembership < ActiveRecord::Base
  acts_as_authorizable

  belongs_to :forum
  belongs_to :role
  belongs_to :user
  
  auth_belongs_to_user :user, :role_association => :role

  scope :with_user, ->(user) { where(user_id: user)}
end
