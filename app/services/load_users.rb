class LoadUsers
  def initialize
    @zendesk = Connectors::Zendesk.new
    @logger = Logger.new("#{Rails.root.to_s}/tmp/load_users")
  end

  def load
    users = []
    users_to_update = []
    next_page = 'users'
    while next_page
      response = @zendesk.get(next_page)
      response["users"].each{|u| users << u}
      next_page = response["next_page"] ? response["next_page"].gsub('https://luizalabs9937.zendesk.com/api/v2', '') : nil
    end

    unless users
      @logger.info "Nenhum usuário encontrado para o fluxo"
      return
    end

    @logger.info "Iniciando Load de Users, #{users.count} contas"
    users.each do |acc|
      find_user = User.find_by(id: acc["id"])
      if find_user
        update_fields = { 
          id: acc["id"], 
          nome: acc["name"], 
          email: acc["email"], 
          organization_id: acc["organization_id"], 
          role: acc["role"],
          group_id: acc["default_group_id"]
        }

        @logger.info "Usuário id: #{acc["id"]} já existe"
        users_to_update << update_fields
        update_fields.each do |key, value|
          if find_user[key] != value
            find_user.update_attribute(key, value)
            @logger.info "Campo #{key} atualizado para o usuário id: #{acc["id"]}"
          end
        end
        next 
      end

      creation_response = User.new(
        id: acc["id"],
        nome: acc["name"],
        email: acc["email"],
        organization_id: acc["organization_id"],
        role: acc["role"],
        group_id: acc["default_group_id"]
      )
      @logger.info "Erro ao criar usuário #{acc["name"]}, errors: #{creation_response.errors.full_messages}" unless creation_response.save
    end

    @logger.info "Load de usuários finalizada"
  end
end