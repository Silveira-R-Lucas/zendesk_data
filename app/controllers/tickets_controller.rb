class TicketsController < ApplicationController
  autocomplete :organization, :nome
  def index
    @prioridades = Ticket.pluck(:prioridade).compact.uniq.sort
    @grupos = Group.pluck(:nome).compact.uniq.sort
    @tickets = Ticket.all
    @categorias = Ticket.pluck(:categoria).compact.uniq.sort
    @status = Ticket.pluck(:status).compact.uniq.sort
    @clientes = Organization.pluck(:nome).compact.uniq.sort
    @clientes.delete("Generic org")

    search_filters

    @tickets = @tickets ? Kaminari.paginate_array(@tickets.order(criado_em: :desc)).page(params[:page]).per(50) : nil

    respond_to do |format|
      format.html
      format.csv { send_data Ticket.to_csv(@tickets), filename: "tickets-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end

  def search_filters
    filtered_tickets = @tickets.clone
    if params[:search].present?
      filtered_tickets= Organization.find_by(nome: params[:search])&.tickets
    elsif params[:start_date].present? && params[:end_date].present?
      range = (params[:start_date].to_date.beginning_of_day)..(params[:end_date].to_date.end_of_day)
      filtered_tickets = filtered_tickets.where(criado_em: range)
    elsif params[:prioridade].present?
      filtered_tickets = filtered_tickets.where(prioridade: params[:prioridade])
    elsif params[:fila].present?
      fila = Group.find_by(nome: params[:fila])&.id
      filtered_tickets = filtered_tickets.where(group_id: fila)
    elsif params[:status].present?
      filtered_tickets = filtered_tickets.where(status: params[:status])
    elsif params[:categoria].present?
      filtered_tickets = filtered_tickets.where(categoria: params[:categoria])
    end

    @tickets = filtered_tickets
  end
end