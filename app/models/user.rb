class User < ActiveRecord::Base
  validates :nome, :id, :presence => true
  has_one  :grupo,
              foreign_key: 'default_group_id',
              class_name: 'Group'
  has_many  :tickets_atribuidos,
              foreign_key: 'assignee_id',
              class_name: 'Ticket'
  has_many :tickets_criados,
              foreign_key: 'requester_id',
              class_name: 'Ticket'
  has_one :organization,
              foreign_key: 'organization_id',
              class_name: 'Organization'
end