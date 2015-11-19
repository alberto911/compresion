require 'rmagick'
include Magick

class Foto < ActiveRecord::Base
  # Cuantización basada en el algoritmo Median cut
  def self.median_cut(img_path, k, dithering)
    img = Image.read(img_path).first
    x = img.export_pixels()
    original_filesize = img.filesize
    
    time = Time.now
    x = x.each_slice(3).to_a
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

    # Recuperar pixeles
    x_recovered = []
    dithering_alg = nil
    if dithering == 0
      sorted.each_with_index do |s, i|
	      s.each do |x|
		      x_recovered[x.last] = centroids[i]
	      end
      end
      x_recovered.flatten!
    elsif dithering == 1
      x_recovered = floyd_steinberg(img, x, centroids)
      dithering_alg = 'Floyd-Steinberg'
    elsif dithering == 2
      x_recovered = ordered_dithering(img, x, centroids)
      dithering_alg = 'Ordenado'
    elsif dithering == 3
      x_recovered = random_dithering(img, x, centroids)
      dithering_alg = 'Aleatorio'
    end
    time = Time.now - time
    
    new_img = Image.new(img.columns, img.rows)
    new_img.import_pixels(0, 0, img.columns, img.rows, "RGB", x_recovered)
    img_blob = new_img.to_blob do
      self.depth = 8
      self.format = 'PNG'
    end
    new_filesize = new_img.filesize    
    
    Foto.guardar_estadistica('Median cut', k, original_filesize, new_filesize, img.columns * img.rows, time, dithering_alg)
    return img_blob
  end

  # Cuantización basada en K-Means Clustering
  def self.k_means(img_path, k, iter, dithering)
    img = Image.read(img_path).first
    x = img.export_pixels()
    size = img.columns * img.rows
    original_filesize = img.filesize

    time = Time.now
   
    # Inicializar con centroides aleatorios
    x = x.each_slice(3).to_a
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
    
    # Recuperar pixeles
    x_recovered = []
    dithering_alg = nil
    if dithering == 0
      for l in 0...k
	      indices[l].each do |i|
		      x_recovered[i] = centroids[l]
	      end
      end
      x_recovered.flatten!
    elsif dithering == 1
      x_recovered = floyd_steinberg(img, x, centroids)
      dithering_alg = 'Floyd-Steinberg'
    elsif dithering == 2
      x_recovered = ordered_dithering(img, x, centroids)
      dithering_alg = 'Ordenado'
    elsif dithering == 3
      x_recovered = random_dithering(img, x, centroids)
      dithering_alg = 'Aleatorio'
    end
    time = Time.now - time

    new_img = Image.new(img.columns, img.rows)
    new_img.import_pixels(0, 0, img.columns, img.rows, "RGB", x_recovered)
    img_blob = new_img.to_blob do
      self.depth = 8
      self.format = 'PNG'
    end
    new_filesize = new_img.filesize    
    
    Foto.guardar_estadistica('K-Means', k, original_filesize, new_filesize, size, time, dithering_alg, iter)
    return img_blob
  end

  private

    # Encontrar el color más cercano a un pixel
    def self.find_closest(pixel, palette)
	    closest_distance = closest_color = nil
	    palette.each do |color|
		    distance = Math.sqrt((pixel[0] - color[0])**2 + (pixel[1] - color[1])**2 + (pixel[2] - color[2])**2)
		    if !closest_distance || distance < closest_distance
			    closest_distance = distance
			    closest_color = color
		    end
	    end
	    closest_color
    end

    # Algoritmo Floyd-Steinberg
    def self.floyd_steinberg(img, x, palette)
      x_recovered = []
      col = img.columns
      size = col * img.rows
      x.each_with_index do |p, i|
	      x_recovered << find_closest(p, palette)
	      error = [p[0] - x_recovered.last[0], p[1] - x_recovered.last[1], p[2] - x_recovered.last[2]]
	      x[i + 1] = [x[i + 1][0] + error[0] * 0.4375, x[i + 1][1] + error[1] * 0.4375, x[i + 1][2] + error[2] * 0.4375] if (i + 1 < size && (i+1)%col != 0)
	      x[i+col-1] = [x[i+col-1][0] + error[0] * 0.1875, x[i+col-1][1] + error[1] * 0.1875, x[i+col-1][2] + error[2] * 0.1875] if (i+col-1 < size && i%col != 0)
	      x[i+col] = [x[i+col][0] + error[0] * 0.3125, x[i+col][1] + error[1] * 0.3125, x[i+col][2] + error[2] * 0.3125] if (i+col < size)
	      x[i+col+1] = [x[i+col+1][0] + error[0] * 0.0625, x[i+col+1][1] + error[1] * 0.0625, x[i+col+1][2] + error[2] * 0.0625] if (i+col+1 < size && (i+1)%col != 0)
      end
      x_recovered.flatten!
    end

	  # Algoritmo de tramado ordenado con una matriz de Bayer
	  def self.ordered_dithering(img, x, palette)
      x_recovered = []
      map = [[1, 9, 3, 11], [13, 5, 15, 7], [4, 12, 2, 10], [16, 8, 14, 6]]
      col = img.columns
      x.each_with_index do |p, i|
	      old = []
	      p.each { |c| old << c + c * map[(i/col) %4][(i%col) %4] / 17.0 }
	      x_recovered << find_closest(old, palette)
      end
      x_recovered.flatten!
	  end

    # Algoritmo de tramado aleatorio
    def self.random_dithering(img, x, centroids)
      x_recovered = []
      generator = Random.new
      palette = centroids.map { |x| [x, x.inject(0) { |sum, n| sum + n**2 }] }
	    palette.sort_by! { |x| x.last }

      x.each do |p|
	      old = []
	      3.times { old << generator.rand(65536) }
	      color = find_closest(p, centroids)
	      index = palette.index([color, color.inject(0) { |sum, n| sum + n**2 }])
	      if (p.reduce(:+) < (old.reduce(:+) * 0.71) && index != 0)
		      x_recovered << palette[index-1].first
	      elsif (p.reduce(:+) > (old.reduce(:+) * 1.4) && index != palette.size-1)
		      x_recovered << palette[index+1].first
	      else
		      x_recovered << color
	      end
      end
      x_recovered.flatten!
    end

    def self.guardar_estadistica(q_alg, col, bi, bf, pix, t, d_alg, iter = nil)
      params = {cuantificacion: q_alg, colores: col, iteraciones: iter, bytes_inicio: bi, bytes_fin: bf, pixeles: pix, tiempo: t, tramado: d_alg}
      Estadistica.create(params)
    end
end
