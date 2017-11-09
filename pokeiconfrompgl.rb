#!/usr/bin/env ruby
require 'curb'
require 'rmagick'
include Magick

class PokeIconHelper
  def initialize
    @url = Curl::Easy.http_get("https://3ds.pokemon-gl.com/share/js/path/3ds.js").body_str.scan(/cmsUploads:"(.*)"/)[0][0]
    @curl = Curl::Easy.new
    @curl.ssl_version = 6
  end

  def convert(imagename)
    image = Image.read(imagename)[0]
    vertical = false
    size = image.columns

    2.times do
      list = ImageList.new
      list << image << image
      image = list.append(vertical)
      vertical = true
    end

    image.crop!(size / 2, size / 2, size, size)
    image.page = Rectangle.new(size / 2, size / 2, 0, 0)
    image.write(imagename)
  end

  def download(monsno, formno)
    code = (0x1000000 | (monsno * 0x9a55e5 + formno * 0xe50000) & 0xffffff).to_s(16)[1..-1]
    newname = "%03d-%02d.png" % [monsno, formno]

    unless File.exist?(newname)
      size = 300
      @curl.url = @url + "/share/images/pokemon/#{size}/#{code}.png"
      @curl.perform

      f = File.new(newname, "w+")
      f.puts @curl.body_str

      if f.size < 308
        f.close
        File.delete(newname)
        return false
      else
        f.close
        puts "Downloading #{newname}..."
        convert(newname)
      end
    end

    true
  end
end

pokeh = PokeIconHelper.new
monsno = 1
fails = 0

until fails > 1 do
  formno = 0

  loop do
    if pokeh.download(monsno, formno)
      fails = 0
    else
      fails += 1
      break
    end

    formno += 1
  end

  monsno += 1
end
