class TicketsController < ApplicationController
  def index
    @prioridades = Ticket.pluck(:prioridade).uniq
    @grupos = Group.pluck(:nome).uniq
    @tickets = Ticket.all

    if params[:search].present?
      @tickets= Organization.find_by(nome: params[:search])&.tickets
    elsif params[:start_date].present? && params[:end_date].present?
      range = (params[:start_date].to_date.beginning_of_day)..(params[:end_date].to_date.end_of_day)
      @tickets = @tickets.where(criado_em: range)
    elsif params[:prioridade].present?
      @tickets = @tickets.where(prioridade: params[:prioridade])
    elsif params[:fila].present?
      @tickets= Group.find_by(nome: params[:fila]).tickets
    end

    @tickets = @tickets ? Kaminari.paginate_array(@tickets.order(criado_em: :desc)).page(params[:page]).per(50) : nil
  end
end