class LoadTickets
  def initialize
    @zendesk = Connectors::Zendesk.new
    @logger = Logger.new("#{Rails.root.to_s}/tmp/load_tickets")
  end

  def load
    tickets = []
    tickets_to_update = []
    next_page = 'tickets'
    while next_page
      response = @zendesk.get(next_page)
      response["tickets"].each{|o| tickets << o}
      next_page = response["next_page"] ? response["next_page"].gsub('https://luizalabs9937.zendesk.com/api/v2', '') : nil
    end

    unless tickets
      @logger.info "Nenhuma ticket encontrado para o fluxo"
      return
    end

    @logger.info "Iniciando Load de tickets, #{tickets.count} tickets"
    tickets.each do |tkt|
      find_tkt = Ticket.find_by(id: tkt["id"])
      if find_tkt
        update_fields = { 
          id: tkt["id"],
          organization_id: tkt["organization_id"], 
          requester_id: tkt["requester_id"], 
          prioridade: tickets.first["tags"].select{|w| w.include?('priori')}.first,
          categoria: tickets.first["tags"].select{|w| w.include?('categ')}.first,
          regiao: tickets.first["tags"].select{|w| w.include?('regiao')}.first,
          tipo_cliente: tickets.first["tags"].select{|w| w.include?('erno')}.first || 'externo',
          tags: tkt["tags"],
          status: tkt["status"],
          group_id: tkt["group_id"],
          atribuido: tkt["assignee_id"],
          observacoes: '',
          criado_em: tkt["created_at"],
          atualizado_em: tkt["updated_at"]
        }
        @logger.info "ticket id: #{tkt["id"]} já existe"
        tickets_to_update << update_fields
        update_fields.each do |key, value| 
          if find_tkt[key] != value
            find_tkt.update_attribute(key, value)
            @logger.info "Campo #{key} atualizado para o ticket id: #{tkt["id"]}"
          end
        end
        next
      end

      creation_response = Ticket.new(
        id: tkt["id"],
        organization_id: tkt["organization_id"], 
        requester_id: tkt["requester_id"], 
        prioridade: tickets.first["tags"].select{|w| w.include?('priori')}.first,
        categoria: tickets.first["tags"].select{|w| w.include?('categ')}.first,
        regiao: tickets.first["tags"].select{|w| w.include?('regiao')}.first,
        tipo_cliente: tickets.first["tags"].select{|w| w.include?('erno')}.first || 'externo',
        tags: tkt["tags"].join('/'),
        status: tkt["status"],
        group_id: tkt["group_id"],
        atribuido: tkt["assignee_id"],
        observacoes: '',
        criado_em: tkt["created_at"],
        atualizado_em: tkt["updated_at"]
      )
      @logger.info "Erro ao criar ticket #{tkt["name"]}, errors: #{creation_response.errors.full_messages}" unless creation_response.save
    end

    @logger.info "Load de tickets finalizado"
  end
end