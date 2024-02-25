class LoadGroups
  def initialize
    @zendesk = Connectors::Zendesk.new
    @logger = Logger.new("#{Rails.root.to_s}/tmp/load_groups")
  end

  def load
    groups = []
    groups_to_update = []
    next_page = 'groups'
    while next_page
      response = @zendesk.get(next_page)
      response["groups"].each{|o| groups << o}
      next_page = response["next_page"] ? response["next_page"].gsub('https://luizalabs9937.zendesk.com/api/v2', '') : nil
    end

    unless groups
      @logger.info "Nenhuma grupo encontrado para o fluxo"
      return
    end

    @logger.info "Iniciando Load de grupos, #{groups.count} grupos"
    groups.each do |grp|
      find_grp = Group.find_by(id: grp["id"])
      if find_grp
        update_fields = { 
          id: grp["id"],
          nome: grp["name"], 
          descricao: grp["description"], 
          criado_em: grp["created_at"],
          atualizado_em:grp["updated_at"]
        }
        @logger.info "grupo id: #{grp["id"]} já existe"
        groups_to_update << update_fields
        update_fields.each do |key, value| 
          if find_grp[key] != value
            find_grp.update_attribute(key, value)
            @logger.info "Campo #{key} atualizado para o grp id: #{grp["id"]}"
          end
        end
        next
      end

      creation_response = Group.new(
        id: grp["id"],
        nome: grp["name"], 
        descricao: grp["description"], 
        criado_em: grp["created_at"],
        atualizado_em:grp["updated_at"]
      )

      @logger.info "Erro ao criar grupp #{grp["name"]}, errors: #{creation_response.errors.full_messages}" unless creation_response.save
    end

    @logger.info "Load de grupos finalizado"
  end
end
