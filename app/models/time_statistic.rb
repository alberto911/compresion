require_relative 'abstract_statistic'

class TimeStatistic < AbstractStatistic
  def data_query(algorithm, average_params)
    Estadistica.where("cuantificacion = ?", algorithm).group(:tramado, :pixeles, :colores).average(average_params)
  end

  def format_keys(data)
    query = {}
    data.each_pair do |k, v|
      if k[0]
        query[[k[0], k[1].to_s + ' x ' + k[2].to_s]] = v
      else
        query[['Sin tramado', k[1].to_s + ' x ' + k[2].to_s]] = v
      end
    end
    query
  end
end
