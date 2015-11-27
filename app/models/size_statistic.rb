require_relative 'abstract_statistic'

class SizeStatistic < AbstractStatistic
  def data_query(algorithm, average_params)
    Estadistica.where("cuantificacion = ?", algorithm).group(:tramado, :colores).average("bytes_inicio / bytes_fin")
  end

  def format_keys(data)
    query = {}
    data.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1]]] = v
      else
        query[['Sin tramado', k[1]]] = v
      end
    end
    query
  end
end
