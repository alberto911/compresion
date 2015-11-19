require 'csv'

class Estadistica < ActiveRecord::Base
	def self.tiempo_k_means
    tiempos = Estadistica.where("cuantificacion = ?", 'K-Means').group(:tramado, :pixeles, :colores).average("tiempo / iteraciones")
    query = {}
    tiempos.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1].to_s + ' x ' + k[2].to_s]] = v
      else
        query[['Sin tramado', k[1].to_s + ' x ' + k[2].to_s]] = v
      end
    end
    query
	end

  def self.tiempo_median_cut
    tiempos = Estadistica.where("cuantificacion != ?", 'K-Means').group(:tramado, :pixeles, :colores).average(:tiempo)
    query = {}
    tiempos.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1].to_s + ' x ' + k[2].to_s]] = v
      else
        query[['Sin tramado', k[1].to_s + ' x ' + k[2].to_s]] = v
      end
    end
    query
  end

  def self.bytes_k_means
    compresion = Estadistica.where("cuantificacion = ?", 'K-Means').group(:tramado, :colores).average("bytes_inicio / bytes_fin")
    query = {}
    compresion.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1]]] = v
      else
        query[['Sin tramado', k[1]]] = v
      end
    end
    query
  end

  def self.bytes_median_cut
    compresion = Estadistica.where("cuantificacion != ?", 'K-Means').group(:tramado, :colores).average("bytes_inicio / bytes_fin")
    query = {}
    compresion.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1]]] = v
      else
        query[['Sin tramado', k[1]]] = v
      end
    end
    query
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ['cuantificacion', 'tramado', 'pixeles', 'colores', 'iteraciones', 'tiempo', 'tamaño inicial', 'tamaño final']
      all.each do |s|
        csv << [s.cuantificacion, s.tramado, s.pixeles, s.colores, s.iteraciones, s.tiempo, s.bytes_inicio, s.bytes_fin]
      end
    end
  end

end
