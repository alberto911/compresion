require 'rmagick'
require 'open-uri'

class FotosController < ApplicationController
  def index
    @metodos = [['Median cut', 1], ['K-Means', 2]]
    @dithering = [['Floyd-Steinberg', 1], ['Ordenado', 2], ['Aleatorio', 3]]
  end

  def import
    if validate_params
      begin
        if params[:method] == '1'
          img = Foto.median_cut(params[:file].path, params[:colors].to_i, params[:dithering].to_i)
        elsif params[:method] == '2'
          img = Foto.k_means(params[:file].path, params[:colors].to_i, params[:iterations].to_i, params[:dithering].to_i)
        end
       
        name = params[:file].original_filename.partition(".")[0] + ".png"
	      send_data img, type: 'image/png', filename: name

        rescue Magick::ImageMagickError
          redirect_to :back, alert: 'Encabezado de imagen incorrecto.'
      end
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
