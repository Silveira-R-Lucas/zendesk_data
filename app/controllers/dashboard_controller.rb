class DashboardController < ApplicationController
  def index
    @org_tickets = {}
    Organization.all.each{|org| @org_tickets[org&.nome] = org.tickets.count if org.tickets.count > 1}
    @tickets = Ticket.all
    hash_regiao = Ticket.group(:regiao).count
    @tkts_filas = {}
    Group.all.each{|grp| @tkts_filas[grp&.nome] = grp.tickets.count }
    @hash_filtrado_tkt_regiao = {'SE-1': 0, 'NE-1': 0, "Não atribuído": 0}
    hash_regiao.each do |k, v|
      if k.to_s.include?('se')
        @hash_filtrado_tkt_regiao[:"SE-1"] += v
      elsif k.to_s.include?('ne')
        @hash_filtrado_tkt_regiao[:"NE-1"] += v
      else
        @hash_filtrado_tkt_regiao[:"Não atribuído"] += v
      end
    end
  end
end