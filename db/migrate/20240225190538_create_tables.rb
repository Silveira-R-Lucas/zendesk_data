class CreateTables < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.integer :organization_id
      t.integer :requester_id
      t.string :prioridade
      t.string :status
      t.integer :group_id
      t.integer :atribuido
      t.string :observacoes
      t.string :categoria
      t.string :regiao
      t.string :tipo_cliente
      t.string :tags
      t.datetime :criado_em
      t.datetime :atualizado_em
    end

    create_table :organizations do |t|
      t.string :nome
      t.string :dominios
      t.string :detalhes
      t.string :tenant
      t.string :tags
      t.datetime :criado_em
      t.datetime :atualizado_em
    end

    create_table :groups do |t|
      t.string :nome
      t.string :descricao
      t.datetime :criado_em
      t.datetime :atualizado_em
    end

    #Há três tipos de Usuários no Zendesk: end users (clientes), agents, and administrators.
    create_table :users do |t|
      t.string :nome
      t.string :email
      t.integer :organization_id
      t.string :role
      t.integer :group_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :systems do |t|
      t.string :url
      t.string :username
      t.string :token
      t.string :password
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end