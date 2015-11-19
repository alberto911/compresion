class ChangeEstadisticas < ActiveRecord::Migration
  def change
    rename_column :estadisticas, :algoritmo, :cuantificacion
	add_column :estadisticas, :tramado, :string
  end
end
