class RegisterObserver  
  def initialize(pixels, colors, initial_size, iterations = nil)
    @register = {}
    @register[:pixeles] = pixels
    @register[:colores] = colors
    @register[:bytes_inicio] = initial_size
    @register[:iteraciones] = iterations
  end

  def update(stage)
    @register[stage.name] = stage.algorithm.name
  end

  def terminate(final_size, time)
    @register[:bytes_fin] = final_size
    @register[:tiempo] = time
    Estadistica.create(@register)
  end
end
