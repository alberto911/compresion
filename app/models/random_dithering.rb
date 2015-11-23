require_relative 'dithering'

class RandomDithering
  attr_reader :name

  def initialize
    @name = 'Aleatorio'
  end

  def dither(x, centroids, img)
    x_recovered = []
    generator = Random.new
    palette = centroids.map { |x| [x, x.inject(0) { |sum, n| sum + n**2 }] }
    palette.sort_by! { |x| x.last }

    x.each do |p|
      old = []
      3.times { old << generator.rand(65536) }
      color = Dithering.find_closest(p, centroids)
      index = palette.index([color, color.inject(0) { |sum, n| sum + n**2 }])
      if (p.reduce(:+) < (old.reduce(:+) * 0.71) && index != 0)
        x_recovered << palette[index-1].first
      elsif (p.reduce(:+) > (old.reduce(:+) * 1.4) && index != palette.size-1)
        x_recovered << palette[index+1].first
      else
        x_recovered << color
      end
    end
    x_recovered.flatten
  end
end
