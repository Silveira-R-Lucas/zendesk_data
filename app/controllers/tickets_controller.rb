class TicketsController < ApplicationController
  autocomplete :organization, :nome
  def index
    @prioridades = Ticket.pluck(:prioridade).compact.uniq.sort
    @grupos = Group.pluck(:nome).compact.uniq.sort
    @tickets = Ticket.all
    @status = Ticket.pluck(:status).compact.uniq.sort
    @clientes = Organization.pluck(:nome).compact.uniq.sort
    @clientes.delete("Generic org")
    if params[:search].present?
      @tickets= Organization.find_by(nome: params[:search])&.tickets
    elsif params[:start_date].present? && params[:end_date].present?
      range = (params[:start_date].to_date.beginning_of_day)..(params[:end_date].to_date.end_of_day)
      @tickets = @tickets.where(criado_em: range)
    elsif params[:prioridade].present?
      priori = nil if params[:prioridade] == 'Sem prioridade atribuída' || params[:prioridade]
      @tickets = @tickets.where(prioridade: priori)
    elsif params[:fila].present?
      fila = Group.find_by(nome: params[:fila])&.id
      @tickets = @tickets.where(group_id: fila)
    elsif params[:status].present?
      @tickets = @tickets.where(status: params[:status])
    end

    @tickets = @tickets ? Kaminari.paginate_array(@tickets.order(criado_em: :desc)).page(params[:page]).per(50) : nil
  end
end