############ NOTES ############ 
# - Frame separator 'black area' around 35px height, but can be as small as 8px tall
# - Supplied image must must be in portrait orientation

module Kinoscan
  class Scanner

    HEX_COLOUR_MAX = 50

    def initialize(image_path, output_path: nil)
      @image_path = image_path
      @output_path = output_path
      @file_name = File.basename(image_path, ".*")
      @image = ::MiniMagick::Image.open image_path
      @pixels = @image.get_pixels
      self
    end

    def call
      puts "Scanning image: #{@image_path}"
      black_pixels = collect_black_rows(@image)
      cleansed_image = scrub_black_pixels(black_pixels)

      puts "Extracting Shot frames"
      frames = extract_shot_frames

      frames.each_with_index do |frame, idx|
        idx += 1
        puts "Saving frame #{idx}"
        save_new_image(frame, idx)
      end

      zip_frames

      puts "Finished scanning: #{@image_path}"
    end

    private

    def collect_black_rows(image)
      black_pixels = []

      image.get_pixels.each_with_index do |pixel_row, row_idx|
        black_pixel_row = []

        pixel_row.each_with_index do |pixel, col_idx|
          # `pixel` represents an RGB value in arr format
          # e.g. [255, 255, 255] == [R, G, B]

          red = pixel[0]
          green = pixel[1]
          blue = pixel[2]

          if red < HEX_COLOUR_MAX && green < HEX_COLOUR_MAX && blue < HEX_COLOUR_MAX
            black_pixel_row << pixel
          end
        end

        black_pixels << black_pixel_row
      end

      black_pixels
    end


    def scrub_black_pixels(black_pixels)
      mostly_black_rows_coords = []
      height_in_rows = []
      counter = 0

      black_pixels.each_with_index do |row, idx|
        mostly_black_rows_coords << idx if row.length > 1000
      end

      @image.height.times do
        counter+=1
        height_in_rows.push(counter)
      end

      @exposed_rows = (height_in_rows - mostly_black_rows_coords)
    end

    def extract_shot_frames

      dead_zone_boundaries = []

      @exposed_rows.each_with_index do |row, idx|
        if @exposed_rows[idx+1] && (@exposed_rows[idx+1]) > (row + 5)
          dead_zone_boundaries << [@exposed_rows[idx], @exposed_rows[idx+1]]
        end
      end

      exposures = []

      if !dead_zone_boundaries.empty? && dead_zone_boundaries.length == 3
        first_image_bounds  = 0..dead_zone_boundaries[0][0]
        second_image_bounds = dead_zone_boundaries[0][1]..dead_zone_boundaries[1][0]
        third_image_bounds  = dead_zone_boundaries[1][1]..dead_zone_boundaries[2][0]
        fourth_image_bounds = dead_zone_boundaries[2][1]..@exposed_rows.last

        exposures = [@pixels[first_image_bounds], @pixels[second_image_bounds], @pixels[third_image_bounds], @pixels[fourth_image_bounds]]
      end 

      exposures
    end

    def save_new_image(frame, idx)
      new_image_height = frame.length
      new_image_width = frame.first.length

      output_file_name = "#{@file_name}-#{idx}.jpg"

      image_file_path = "#{@output_path}/#{output_file_name}"

      puts "New image file path: #{image_file_path}"

      blob = frame.compact.flatten.pack("C*")

      img = MiniMagick::Image.import_pixels(blob, new_image_width, new_image_height, 8, "rgb", "jpg")

      img.write(image_file_path)
    end

    def zip_frames
      zipfile_name = "#{@file_name}-frames.zip"

      zipfile_path = "#{zipfile_name}"
      zipfile_path = "#{@output_path}/#{zipfile_path}" if @output_path

      puts "Zipping frames: #{zipfile_path}"
      zip = Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
        (1..4).each do |id|
          file_path = "#{@file_name}-#{id}.jpg"
          file_path = "#{@output_path}/#{@file_name}-#{id}.jpg" if @output_path
          zipfile.add("#{@file_name}-#{id}.jpg", file_path)
        end

        zipfile
      end

      zip
    end
  end
end