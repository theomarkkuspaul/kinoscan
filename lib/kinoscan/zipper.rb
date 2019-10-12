module Kinoscan
  class Zipper
    attr_reader :frames, :output_dest

    def initialize(frames:, output_dest:)
      @frames = frames
      @output_dest = output_dest
    end

    def call
      zip = Zip::File.open(output_dest, Zip::File::CREATE) do |zipfile|
        frames.each do |frame_path|
          file_name = File.basename frame_path
          zipfile.add(file_name, frame_path)
        end

        zipfile
      end

      options = {
        cloud_name: "dfhcqhhie",
        api_key: ENV['CLOUDINARY_API_KEY'],
        api_secret: ENV['CLOUDINARY_SECRET_KEY'],
        resource_type: :raw
      }

      # upload to da cloud
      Cloudinary::Uploader.upload(output_dest, options)
    end

  end
end
