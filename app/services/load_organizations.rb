class LoadOrganizations
  def initialize
    @zendesk = Connectors::Zendesk.new
    @logger = Logger.new("#{Rails.root.to_s}/tmp/load_organizations")
  end

  def load
    organizations = []
    organizations_to_update = []
    next_page = 'organizations'
    while next_page
      response = @zendesk.get(next_page)
      response["organizations"].each{|o| organizations << o}
      next_page = response["next_page"] ? response["next_page"].gsub('https://luizalabs9937.zendesk.com/api/v2', '') : nil
    end

    unless organizations
      @logger.info "Nenhuma organização encontrado para o fluxo"
      return
    end

    @logger.info "Iniciando Load de organizações, #{organizations.count} organizações"
    organizations.each do |org|
      find_org = Organization.find_by(id: org["id"])
      if find_org
        update_fields = { 
          id: org["id"],
          nome: org["name"], 
          dominios: org["domain_names"], 
          detalhes: org["details"], 
          tenant: org["notes"], 
          tags: org["tags"],
          criado_em: org["created_at"],
          atualizado_em:org["updated_at"]
        }
        @logger.info "Organização id: #{org["id"]} já existe"
        organizations_to_update << update_fields
        update_fields.each do |key, value| 
          if find_org[key] != value
            find_org.update_attribute(key, value)
            @logger.info "Campo #{key} atualizado para o org id: #{org["id"]}"
          end
        end
        next
      end

      creation_response = Organization.new(
        id: org["id"],
        nome: org["name"],
        dominios: org["domain_names"], 
        detalhes: org["details"], 
        tenant: org["notes"], 
        tags: org["tags"],
        criado_em: org["created_at"],
        atualizado_em:org["updated_at"]
      )

      @logger.info "Erro ao criar org #{org["name"]}, errors: #{creation_response.errors.full_messages}" unless creation_response.save
    end

    @logger.info "Load de Organizações finalizado"
  end
end