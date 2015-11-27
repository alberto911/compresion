class AbstractStatistic
  def get_statistic(algorithm , average = nil)
    data = data_query(algorithm, average)
    format_keys(data)
  end

  def data_query(algorithm, average)
  end

  def format_keys(data)
  end
end
