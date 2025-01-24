# frozen_string_literal: true

module Utils
  # class for generating QR codes
  class QrCodeBuilder
    def self.build(config)
      new(config).build
    end

    def initialize(config)
      @text = ConfigFileBuilder.build(config)
    end

    def build
      qr = RQRCode::QRCode.new(text)
      png = qr.as_png(**qr_code_params)
      file = Tempfile.new

      File.open(file, 'wb') do |f|
        binary_data = png.to_s
        f.write(binary_data)
      end

      file.rewind
      file
    end

    private

    def qr_code_params # rubocop:disable Metrics/MethodLength
      {
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 800
      }
    end

    attr_reader :text
  end
end
