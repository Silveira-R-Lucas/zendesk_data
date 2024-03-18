class AddColumnsToTktTable < ActiveRecord::Migration[6.1]
  def change
    change_table(:tickets) do |t|
      t.column :titulo, :string
      t.column :descricao, :string
    end
  end
end
