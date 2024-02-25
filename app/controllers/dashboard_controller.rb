class DashboardController < ApplicationController
  def index
    @org_tickets = {}
    Organization.all.each{|org| @org_tickets[org.nome] = org.tickets.count if org.tickets.count > 1}
    @tickets = Ticket.all
  end
end