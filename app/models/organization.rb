class Organization < ActiveRecord::Base
  validates :nome, :id, :presence => true
  has_many :users
  has_many :tickets
end