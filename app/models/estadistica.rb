require 'csv'

class Estadistica < ActiveRecord::Base
  def self.to_csv
    CSV.generate do |csv|
      csv << ['cuantificacion', 'tramado', 'pixeles', 'colores', 'iteraciones', 'tiempo', 'tamaño inicial', 'tamaño final']
      all.each do |s|
        csv << [s.cuantificacion, s.tramado, s.pixeles, s.colores, s.iteraciones, s.tiempo, s.bytes_inicio, s.bytes_fin]
      end
    end
  end
end
