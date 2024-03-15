class Ticket < ActiveRecord::Base
  validates :status, :id, :presence => true
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

  scope :search, -> search { where(organization_id: Organization.find_by(nome: search)&.id) }
  scope :fila, -> fila { where(group_id: Group.find_by(nome: fila)&.id)}   
  scope :categoria, -> categoria {where(categoria: categoria)}
  scope :status, -> status {where(status: status)}
  scope :prioridade, -> prioridade {where(prioridade: prioridade)}
  scope :by_period, -> range { where(criado_em: range) }

  require 'csv'

  FILTERS = %w[criado_em].freeze

  def self.to_csv(tickets)
    CSV.generate do |csv|
      csv <<  %w(ID Criado_em Cliente Prioridade Status Fila Atribuído)
      tickets.each do |ticket|
        valores = [
          ticket.id,
          ticket.criado_em.strftime('%Y-%m-%d'),
          (ticket.tipo_cliente if ticket.organization&.nome == "Generic org") || ticket.organization&.nome || ticket.tipo_cliente,
          ticket.prioridade || 'Sem prioridade atribuída',
          ticket.status,
          ticket.group&.nome,
          ticket.usuario_atribuido&.nome
        ]
        csv << valores
      end
    end
  end
end