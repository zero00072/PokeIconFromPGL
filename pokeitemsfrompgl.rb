#!/usr/bin/env ruby
require "curb"
require "rmagick"
include Magick

class PokeIconHelper
  def initialize
    @url = Curl::Easy.http_get("https://3ds.pokemon-gl.com/share/js/path/3ds.js").body_str.scan(/cmsUploads:"(.*)"/)[0][0]
    @curl = Curl::Easy.new
    @curl.ssl_version = 6
  end

  def convert(imagename)
    image = Image.read(imagename)[0]
    image.write(imagename)
    image.destroy!
  end

  def download(itemno)
    code = (0x1000000 | (itemno * 0x9a55e5) & 0xffffff).to_s(16)[1..-1]
    newname = "%03d.png" % itemno

    unless File.exist?(newname)
      @curl.url = @url + "/share/images/item/#{code}.png"
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
itemno = 0
fails = 0

until fails > 500 do
  if pokeh.download(itemno)
    fails = 0
  else
    fails += 1
  end

  itemno += 1
end
