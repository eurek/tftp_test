module ActiveStorage
  class Attached
    def attach_from_url(url, headers = {})
      if url.blank?
        purge if is_a?(Attached::One)
        return
      end

      filename = File.basename(URI.parse(url).path).presence || "image.jpg"
      io = URI.download_to_file(url, headers)
      checksum = Digest::MD5.file(io).base64digest
      existing_blob = ActiveStorage::Blob.find_by(checksum: checksum)
      if existing_blob.present?
        attach(existing_blob)
      else
        io.rewind
        attach(io: io, filename: filename)
        io.unlink
      end
    end
  end
end

module ActiveStorageCallback
  extend ActiveSupport::Concern

  included do
    after_create_commit :file_uploaded

    def file_uploaded
      record.try(:file_uploaded)
    end
  end
end

ActiveStorage::Attachment.send :include, ActiveStorageCallback
