# inspired from https://github.com/turbo/pg-shortkey/blob/ba6e6a28213775f1604d1841938e930778c86c56/pg-shortkey.sql#L37
module ShortKey
  def self.generate
    SecureRandom.base64(8)
      .tr("/", "_")
      .tr("+", "_")
      .chomp("=")
  end

  def self.format_regex
    /\A[A-Za-z0-9_]{11}\z/
  end
end
