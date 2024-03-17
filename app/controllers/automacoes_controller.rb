class AutomacoesController < ApplicationController

  def index
  end

  def sync_users
    service = LoadUsers.new

    if service.load
      redirect_to request.referrer, notice: 'Usuários Sincronizados.'
    else
      flash[:error] = 'Erro na sincronização =('
      redirect_to request.referrer
    end
  end

  def sync_clients
    service = LoadOrganizations.new

    if service.load
      redirect_to request.referrer, notice: 'Clientes Sincronizados.'
    else
      flash[:error] = 'Erro na sincronização =('
      redirect_to request.referrer
    end
  end

  def sync_squads
    service = LoadGroups.new

    if service.load
      redirect_to request.referrer, notice: 'Squads Sincronizados.'
    else
      flash[:error] = 'Erro na sincronização =('
      redirect_to request.referrer
    end
  end

  def sync_tickets
    service = LoadTickets.new

    if service.load
      redirect_to request.referrer, notice: 'Tickets Sincronizados.'
    else
      flash[:error] = 'Erro na sincronização =('
      redirect_to request.referrer
    end
  end
end