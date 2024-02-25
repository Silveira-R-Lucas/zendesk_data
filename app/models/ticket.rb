class Ticket < ActiveRecord::Base
  validates :status, :id, :prioridade, :presence => true
  has_one  :grupo
  belongs_to  :organization,
              foreign_key: 'organization_id',
              class_name: 'Organization'
  belongs_to  :usuario_atribuido,
              foreign_key: 'atribuido',
              class_name: 'User'
  belongs_to  :usuario_criador,
            foreign_key: 'requester_id',
            class_name: 'User'
  belongs_to :group,
            foreign_key: 'group_id',
            class_name: 'Group'
end