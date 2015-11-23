require_relative 'quantizer'

class MedianCut < Quantizer
  def initialize
    @name = 'Median cut'
  end

  def quantize(x, k, iter = nil, size = nil)
    time = Time.now
    sorted = [x.map.with_index.to_a]

    # Dividir el grupo más grande en dos
    for i in 1...k
	    puts i
	    maxEje = maxBox = nil
	    sorted.each_with_index do |s, i|
		    rangos = []
		    rangos[0] = s.minmax_by { |x| x.first[0] }.map { |x| x.first[0] }.reverse.reduce(:-)
		    rangos[1] = s.minmax_by { |x| x.first[1] }.map { |x| x.first[1] }.reverse.reduce(:-)
		    rangos[2] = s.minmax_by { |x| x.first[2] }.map { |x| x.first[2] }.reverse.reduce(:-)

		    if (!maxEje || rangos.max > maxEje.first)
			    maxEje = rangos.each_with_index.max
			    maxBox = i
		    end
	    end

	    newBoxes = sorted[maxBox].sort_by { |x| x.first[maxEje.last] }
	    newBoxes.each_slice(newBoxes.size/2 + newBoxes.size%2).to_a.each { |x| sorted << x}
	    sorted.delete_at maxBox
    end

    # Calcular centroides
    centroids = []
    sorted.each do |s|
	    sum_red = sum_green = sum_blue = 0
	    s.each do |x|
		    sum_red += x.first[0]
		    sum_green += x.first[1]
		    sum_blue += x.first[2]
	    end
	    centroids << [sum_red/s.size, sum_green/s.size, sum_blue/s.size]
    end

    return [centroids, sorted]
  end

  def recover(centroids, indices)
    x_recovered = []
    indices.each_with_index do |s, i|
      s.each do |x|
	    	x_recovered[x.last] = centroids[i]
      end
    end
    x_recovered.flatten!
  end
end
