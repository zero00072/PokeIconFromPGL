#!/usr/bin/env ruby
require 'curb'
require 'rmagick'
include Magick

class PokeIconHelper
  attr_reader :spmons

  def initialize
    @url = Curl::Easy.http_get("http://3ds.pokemon-gl.com/share/js/path/3ds.js").body_str.scan(/cmsUploads:"(.*)"/)[0][0]
    @spmons = {
      25  => 7,
      201 => 28,
      351 => 4,
      386 => 4,
      412 => 3,
      413 => 3,
      422 => 2,
      423 => 2,
      479 => 6,
      487 => 2,
      492 => 2,
      493 => 18,
      550 => 2,
      555 => 2,
      585 => 4,
      586 => 4,
      641 => 2,
      642 => 2,
      645 => 2,
      646 => 3,
      647 => 2,
      648 => 2,
      649 => 5,
      666 => 20,
      669 => 5,
      670 => 6,
      671 => 5,
      676 => 10,
      681 => 2,
      710 => 4,
      711 => 4,
      720 => 2
    }
    @curl = Curl::Easy.new
    @curl.ssl_verify_peer = false
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
    image.write(imagename)
  end

  def download(monsno, formno)
    code = (0x1000000 | (monsno * 0x59a55e5 + formno * 0x5e50000) & 0xffffff).to_s(16)[1..-1]
    newname = formno > 0 ? "%03d-%02d.png" % [monsno, formno] : "%03d.png" % monsno

    unless File.exist?(newname)
      puts "Downloading #{newname}..."
      size = 300
      @curl.url = @url + "/share/images/pokemon/#{size}/#{code}.png"
      @curl.perform

      f = File.new(newname, "w+")
      f.puts @curl.body_str
      f.close

      convert(newname)
    end
  end
end

pokeh = PokeIconHelper.new
1.upto(721) do |monsno|
  forms = pokeh.spmons.include?(monsno) ? pokeh.spmons[monsno] : 1
  forms.times do |formno|
    pokeh.download(monsno, formno)
  end
end
