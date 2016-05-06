class User < ActiveRecord::Base
  has_many :conversations
end
