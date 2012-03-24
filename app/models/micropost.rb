class Micropost < ActiveRecord::Base
  attr_accessible :content

  validates :user_id, presence: true
end
