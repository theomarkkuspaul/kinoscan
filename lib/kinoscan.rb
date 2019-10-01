require "kinoscan/version"
require "kinoscan/scanner"

require 'mini_magick'

module Kinoscan
  class Error < StandardError; end
  # Your code goes here...
end

# files = Dir.entries(IMAGES_DIR).select {|f| !File.directory? f}
# files.delete('.DS_Store')

# files.each do |file_path|
#   file_path = "photos/#{file_path}"
#   scanner = KinoScan.new(file_path)
#   scanner.call
# end