require "open-uri"

module URI
  # We must use this method only if we trust the user input (uri)
  def self.download_to_file(uri, headers = {})
    # rubocop:disable Security/Open
    stream = URI.open(uri, "rb", **headers)
    # rubocop:enable Security/Open
    return stream if stream.respond_to?(:path) # Already file-like

    Tempfile.new.tap do |file|
      file.binmode
      IO.copy_stream(stream, file)
      stream.close
      file.rewind
    end
  end
end
