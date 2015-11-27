require_relative 'dithering'
require_relative 'ditherer'

class OrderedDithering < Ditherer
  def initialize
    @name = 'Ordenado'
  end

  def dither(x, palette, img)
    x_recovered = []
    map = [[1, 9, 3, 11], [13, 5, 15, 7], [4, 12, 2, 10], [16, 8, 14, 6]]
    col = img.columns
    x.each_with_index do |p, i|
        old = []
        p.each { |c| old << c + c * map[(i/col) %4][(i%col) %4] / 17.0 }
        x_recovered << Dithering.find_closest(old, palette)
    end
    x_recovered.flatten!
  end
end
