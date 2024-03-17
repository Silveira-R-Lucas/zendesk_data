class DashboardController < ApplicationController
  has_scope :fila
  has_scope :categoria 
  has_scope :status 
  has_scope :prioridade

  def index
    range = if params[:started_at].present? && params[:ended_at].present?
      [(params[:started_at].to_date.beginning_of_day)..(params[:ended_at].to_date.end_of_day)]
    end 
    list = params.select{|k| k.include?('search_filter')}.values
    @categorias = Ticket.pluck(:categoria).compact.uniq.sort
    @status = Ticket.pluck(:status).compact.uniq.sort
    @clientes = Organization.pluck(:nome).compact.uniq.sort
    @clientes.delete("Generic org")
    @prioridades = Ticket.pluck(:prioridade).compact.uniq.sort
    @grupos = Group.pluck(:nome).compact.uniq.sort
    @tickets = tickets_query(range, list)
    @org_tickets = filter_organizations
    @hash_filtrado_tkt_regiao = filter_regiao
    @tkts_filas = filter_groups
    @tkt_prior = @tickets.group(:prioridade).count
    @time_tkt_ctg = timeline_tkt_ctg
    @time_tkt = timeline_tkt
    params["include-null-vls"] ||= "off"
    remove_null_att if params["include-null-vls"] == "off"
  end


  def timeline_tkt
    @tickets.group_by_month(:criado_em, format: "%b").count
    if params[:timeline] == 'Dia'
      return @tickets.group_by_day(:criado_em).count
    elsif params[:timeline] == 'Semana'
      return @tickets.group_by_week(:criado_em).count
    elsif params[:timeline] == 'Mês'
      return @tickets.group_by_month(:criado_em, format: "%b").count
    else
      return @tickets.group_by_month(:criado_em, format: "%b").count
    end
  end

  def timeline_tkt_ctg
    if params[:timeline] == 'Dia'
      return @tickets.group(:categoria).group_by_day(:criado_em).count
    elsif params[:timeline] == 'Semana'
      return @tickets.group(:categoria).group_by_week(:criado_em).count
    elsif params[:timeline] == 'Mês'
      return @tickets.group(:categoria).group_by_month(:criado_em).count
    else
      return @tickets.group(:categoria).group_by_month(:criado_em).count
    end
  end

  def tickets_query(range, list)
    return apply_scopes(Ticket).all if range.blank? && list.blank?
    return apply_scopes(Ticket).all.by_period(range).by_clientes(list) if range.present? && list.present?
    return apply_scopes(Ticket).all.by_period(range) if range.present?
    return apply_scopes(Ticket).all.by_clientes(list) if list.present?
  end

  def filter_regiao
    hash_regiao = @tickets.group(:regiao).count
    clean_values = {'Sudeste' => 0, 'Nordeste' => 0, "Não atribuído" => 0}
    hash_regiao.each do |k, v|
      if k.to_s.include?('se')
        clean_values["Sudeste"] += v
      elsif k.to_s.include?('ne')
        clean_values["Nordeste"] += v
      else
        clean_values["Não atribuído"] += v
      end
    end

    clean_values
  end

  def filter_organizations
    clean_values = {}
    @tickets.group(:organization_id).count.each do |k, v|
      org = Organization.find_by(id: k)
      clean_values[org&.nome] = v if v > 1
    end

    clean_values.reject{ |k| k == nil }
  end

  def filter_groups
    clean_values = {}
    @tickets.group(:group_id).count.each do |k, v|
      grp = Group.find_by(id: k)
      clean_values[grp&.nome] = v if v > 1
    end

    clean_values
  end

  def remove_null_att
    @org_tickets.delete("Generic org")
    @hash_filtrado_tkt_regiao.delete("Não atribuído")
    @tkts_filas.delete("Não atribuído")
    @tkt_prior.delete("Não atribuído")
    @tkt_prior.delete(nil)
    @time_tkt_ctg.reject!{|k| k[0] == "Não atribuído"}
  end
end