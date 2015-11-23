require_relative 'dithering'

class FloydSteinberg
  attr_reader :name

  def initialize
    @name = 'Floyd-Steinberg'
  end

  def dither(x, palette, img)
    x_recovered = []
    col = img.columns
    size = col * img.rows
    x.each_with_index do |p, i|
        x_recovered << Dithering.find_closest(p, palette)
        error = [p[0] - x_recovered.last[0], p[1] - x_recovered.last[1], p[2] - x_recovered.last[2]]
        x[i + 1] = [x[i + 1][0] + error[0] * 0.4375, x[i + 1][1] + error[1] * 0.4375, x[i + 1][2] + error[2] * 0.4375] if (i + 1 < size && (i+1)%col != 0)
        x[i+col-1] = [x[i+col-1][0] + error[0] * 0.1875, x[i+col-1][1] + error[1] * 0.1875, x[i+col-1][2] + error[2] * 0.1875] if (i+col-1 < size && i%col != 0)
        x[i+col] = [x[i+col][0] + error[0] * 0.3125, x[i+col][1] + error[1] * 0.3125, x[i+col][2] + error[2] * 0.3125] if (i+col < size)
        x[i+col+1] = [x[i+col+1][0] + error[0] * 0.0625, x[i+col+1][1] + error[1] * 0.0625, x[i+col+1][2] + error[2] * 0.0625] if (i+col+1 < size && (i+1)%col != 0)
    end
    x_recovered.flatten!
  end
end
