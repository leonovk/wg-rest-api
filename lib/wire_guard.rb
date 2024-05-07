# frozen_string_literal: true

# wg
class WireGuard
  WG_PATH = '/etc/wireguard'

  def create
    filename = 'my_file.txt'
    content = 'This is the content of the file.'
    file_path = File.join(WG_PATH, filename)

    File.open(file_path, 'w') do |file|
      file.write(content)
    end
  end
end
