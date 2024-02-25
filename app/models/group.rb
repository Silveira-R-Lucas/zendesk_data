class Group < ActiveRecord::Base
  validates :nome, :id, :presence => true
  has_many :tickets
  has_many :users
end