class Dithering
  include Subject

  attr_reader :image, :palette, :pixels, :name
  attr_accessor :algorithm

  def initialize(image, pixels, palette)
    super()
    @name = :tramado
    @image = image
    @pixels = pixels
    @palette = palette
  end

  def dither
    notify_all
    @algorithm.dither(pixels, palette, image)
  end

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
end
