class LoadTickets
  def initialize
    @zendesk = Connectors::Zendesk.new
    @logger = Logger.new("#{Rails.root.to_s}/tmp/load_tickets")
  end

  def load
    tickets = []
    next_page = 'tickets'
    while next_page
      response = @zendesk.get(next_page)
      response["tickets"].each{|t| tickets << t}
      next_page = response["next_page"] ? response["next_page"].gsub('https://luizalabs9937.zendesk.com/api/v2', '') : nil
    end

    unless tickets
      @logger.info "Nenhuma ticket encontrado para o fluxo"
      return
    end

    @logger.info "Iniciando Load de tickets, #{tickets.count} tickets"
    tickets.each do |tkt|
      find_tkt = Ticket.find_by(id: tkt["id"])
      payload = {
        id: tkt["id"],
        requester_id: tkt["requester_id"], 
        prioridade: tkt["tags"].find{|w| w.include?('priori')}|| 'Não atribuído',
        categoria: tkt["tags"].find{|w| w.include?('categ')} || 'Não atribuído',
        regiao: tkt["tags"].find{|w| w.include?('regiao')}|| 'Não atribuído',
        tipo_cliente: tkt["tags"].find{|w| w.include?('erno')} || 'externo',
        tags: tkt["tags"],
        status: tkt["status"],
        group_id: tkt["group_id"],
        observacoes: '',
        criado_em: ActiveSupport::TimeZone["America/Sao_Paulo"].parse(tkt["created_at"].to_s),
        atualizado_em: ActiveSupport::TimeZone["America/Sao_Paulo"].parse(tkt["updated_at"].to_s)
      }
      
      if tkt["assignee_id"]
        payload.merge!({atribuido: tkt["assignee_id"]})
      else
        #atribuí a um usuário genérico
        payload.merge!({atribuido: 7})
      end

      if tkt["organization_id"]
        payload.merge!({organization_id: tkt["organization_id"]})
      else
        #chamado aberto via whatasapp/utras plataformas o campo de organização vêm de outra forma
        org = tkt["tags"].find{|w| w.include?('org:')}&.split(':')&.last&.to_i
        org = (Organization.find_by(id: org)&.id if org) || 7
        payload.merge!({organization_id: org,requester_id: 8})
      end

      if find_tkt
        @logger.info "ticket id: #{tkt["id"]} já existe"
        payload.each do |key, value| 
          if find_tkt[key] != value
            find_tkt.update_attribute(key, value)
            @logger.info "Campo #{key} atualizado para o ticket id: #{tkt["id"]}"
          end
        end
        next
      end

      creation_response = Ticket.new(
        payload
      )
      @logger.error "Erro ao criar ticket #{tkt["name"]}, \n Payload: #{payload} \n errors: #{creation_response.errors.full_messages}" unless creation_response.save
    end

    @logger.info "Load de tickets finalizado"
  end
end