require_relative 'quantizer'

class KMeans < Quantizer
  def initialize
    @name = 'K-Means'
  end

  def quantize(x, k, iter = nil, size = nil)
    time = Time.now
   
    # Inicializar con centroides aleatorios
    centroids = []
    (0...size).to_a.sample(k).each { |index| centroids.push(x[index]) }

    for i in 1..iter
      puts "Iteración " + i.to_s + " de " + iter.to_s
	    # Asignar cada pixel a un centroide
	    indices = Array.new(k) { Array.new }
	    x.each_with_index do |p, j|
		    min = min_centroid = nil
		    for l in 0...k
			    tmp = (p[0] - centroids[l][0])**2 + (p[1] - centroids[l][1])**2 + (p[2] - centroids[l][2])**2
			    if (!min || tmp < min)
				    min = tmp
				    min_centroid = l
			    end
		    end
		    indices[min_centroid] << j
	    end
	
	    # Calcular nuevos centroides
	    for l in 0...k
		    unless indices[l].size == 0
			    sum_red = sum_green = sum_blue = 0
			    indices[l].each do |i|
				    sum_red += x[i][0]
				    sum_green += x[i][1]
				    sum_blue += x[i][2]
			    end
			    centroids[l] = [sum_red/indices[l].size, sum_green/indices[l].size, sum_blue/indices[l].size]
		    end
	    end
    end

    return [centroids, indices]
  end

  def recover(centroids, indices)
    x_recovered = []
    centroids.each_with_index do |centroid, l|
      indices[l].each do |i|
	      x_recovered[i] = centroid
      end
    end
    x_recovered.flatten!
  end
end
