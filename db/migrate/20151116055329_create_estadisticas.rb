class CreateEstadisticas < ActiveRecord::Migration
  def change
    create_table :estadisticas do |t|
      t.string :algoritmo, null: false
      t.integer :colores, null: false
      t.integer :iteraciones
      t.integer :bytes_inicio, null: false 
      t.integer :bytes_fin, null: false
      t.integer :pixeles, null: false
      t.float :tiempo, null: false

      t.timestamps null: false
    end
  end
end
