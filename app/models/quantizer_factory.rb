require_relative 'k_means'
require_relative 'median_cut'

class QuantizerFactory
  include Subject

  attr_reader :algorithm, :name

  def initialize
    super()
    @name = :cuantificacion
  end

  def get_quantizer(algorithm)
    case algorithm
      when :k_means then @algorithm = KMeans.new
      when :median_cut then @algorithm = MedianCut.new
      else nil
    end
    notify_all
    @algorithm
  end
end
