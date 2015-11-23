require 'rmagick'
require 'quantizer_factory'
require 'dithering'
require 'floyd_steinberg'
require 'ordered_dithering'
require 'random_dithering'

class FotosController < ApplicationController
  before_action :validate_params, only: :import

  def index
    @metodos = [['Median cut', 1], ['K-Means', 2]]
    @dithering = [['Floyd-Steinberg', 1], ['Ordenado', 2], ['Aleatorio', 3]]
  end

  def import
    begin
      image = Magick::Image.read(params[:file].path).first
      pixels = image.export_pixels().each_slice(3).to_a
      size = image.columns * image.rows
      time = Time.now

      register = RegisterObserver.new(size, params[:colors], image.filesize, params[:iterations].empty? ? nil : params[:iterations])
      quantizer_factory = QuantizerFactory.new
      quantizer_factory.add_observer(register)

      if params[:method] == '1'
        quantizer = quantizer_factory.get_quantizer(:median_cut)
        quantization = quantizer.quantize(pixels, params[:colors].to_i)
      elsif params[:method] == '2'
        quantizer = quantizer_factory.get_quantizer(:k_means)
        quantization = quantizer.quantize(pixels, params[:colors].to_i, params[:iterations].to_i, size)
      end

      ditherer = Dithering.new(image, pixels, quantization.first)
      ditherer.add_observer(register)

      if (params[:dithering].to_i == 0)
        x_recovered = quantizer.recover(quantization[0], quantization[1])
      else
        case params[:dithering]
          when '1' then ditherer.algorithm = FloydSteinberg.new
          when '2' then ditherer.algorithm = OrderedDithering.new
          when '3' then ditherer.algorithm = RandomDithering.new
          else nil
        end
        x_recovered = ditherer.dither
      end

      new_img = Magick::Image.new(image.columns, image.rows)
      new_img.import_pixels(0, 0, image.columns, image.rows, "RGB", x_recovered)
      img_blob = new_img.to_blob do
        self.depth = 8
        self.format = 'PNG'
      end

      register.terminate(new_img.filesize, Time.now - time)
     
      name = params[:file].original_filename.partition(".")[0] + "_compressed.png"
      send_data img_blob, type: 'image/png', filename: name

      rescue Magick::ImageMagickError
        redirect_to :back, alert: 'Encabezado de imagen incorrecto.'
    end
  end

  private
    def validate_params
      if params[:file].nil?
        redirect_to :back, alert: 'No has seleccionado una imagen.'
      elsif params[:file].content_type != 'image/png'
        redirect_to :back, alert: 'La imagen debe estar en formato PNG.'
      elsif params[:method] == ''
        redirect_to :back, alert: 'No has seleccionado un método de cuantificación.'
      elsif params[:colors].to_i < 2
        redirect_to :back, alert: 'El número mínimo de colores es 2.'
      elsif params[:method] == '2' && params[:iterations].to_i < 1
        redirect_to :back, alert: 'El número mínimo de iteraciones es 1.'
      else
        return true;
      end
      return false;
    end
end
