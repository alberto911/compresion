class EstadisticasController < ApplicationController
  def index
    @estadisticas = Estadistica.all
    respond_to do |format|
      format.html
      format.csv { send_data @estadisticas.to_csv }
    end
  end

  def stats
    time_query = TimeStatistic.new
    @time_k = time_query.get_statistic('K-Means', 'tiempo / iteraciones')
    @time_m = time_query.get_statistic('Median cut', 'tiempo')

    size_query = SizeStatistic.new
    @bytes_k = size_query.get_statistic('K-Means')
    @bytes_m = size_query.get_statistic('Median cut')

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'stats',
        javascript_delay: 1000,
        page_size: 'Letter',
        layout: 'layouts/application.pdf.erb'
      end
    end
  end
end
