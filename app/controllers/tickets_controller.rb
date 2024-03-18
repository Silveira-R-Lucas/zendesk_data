class TicketsController < ApplicationController
  autocomplete :organization, :nome
  has_scope :search_by_client
  has_scope :search_by_title
  has_scope :search_by_description
  has_scope :fila
  has_scope :categoria 
  has_scope :status 
  has_scope :prioridade
  
  def index
    range = if params[:started_at].present? && params[:ended_at].present?
              [(params[:started_at].to_date.beginning_of_day)..(params[:ended_at].to_date.end_of_day)]
            end 
    @prioridades = Ticket.pluck(:prioridade).compact.uniq.sort
    @grupos = Group.pluck(:nome).compact.uniq.sort
    @tickets = range ? apply_scopes(Ticket).all.by_period(range) : apply_scopes(Ticket).all
    @categorias = Ticket.pluck(:categoria).compact.uniq.sort
    @status = Ticket.pluck(:status).compact.uniq.sort
    @clientes = Organization.pluck(:nome).compact.uniq.sort
    @clientes.delete("Generic org")
    sort_column = params[:sort] || "criado_em"
    sort_direction = params[:direction].presence_in(%w[asc desc]) || "desc"
    @tickets = @tickets ? Kaminari.paginate_array(@tickets.order("#{sort_column} #{sort_direction}")).page(params[:page]).per(50) : nil
    
    respond_to do |format|
      format.html
      format.csv { send_data Ticket.to_csv(@tickets), filename: "tickets-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end
end