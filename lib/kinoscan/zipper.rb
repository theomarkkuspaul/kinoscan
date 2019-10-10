module Kinoscan
  class Zipper
    ZIPFILE_NAME = "kinoscan.zip"

    attr_reader :frames, :output_dest

    def initialize(frames:, output_dest:)
      @frames = frames
      @output_dest = output_dest
    end

    def call
      zipfile_path = output_dest + ZIPFILE_NAME

      zip = Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
        frames.each do |frame_path|
          file_name = File.basename frame_path
          zipfile.add(file_name, frame_path)
        end

        zipfile
      end

      zip
    end

  end
end
