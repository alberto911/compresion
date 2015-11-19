class EstadisticasController < ApplicationController
  def index
	  @estadisticas = Estadistica.all
    respond_to do |format|
      format.html
      format.csv { send_data @estadisticas.to_csv }    
	  end
  end

  def stats
	  @k_means = Estadistica.tiempo_k_means
	  @tiempo = Estadistica.tiempo_median_cut
	  @bytes_k = Estadistica.bytes_k_means
    @bytes_m = Estadistica.bytes_median_cut

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
