require "active_support/all"

class String
  # https://stackoverflow.com/a/74029319/1439489
  # https://stackoverflow.com/a/70782656/1439489

  DIACRITICS = [*0x1DC0..0x1DFF, *0x0300..0x036F, *0xFE20..0xFE2F].pack("U*")
  def unaccent
    unicode_normalize(:nfkd)
      .tr(DIACRITICS, "")
      .unicode_normalize(:nfc)
      .gsub(self.class.ligature_chars_regex) { |c| self.class.ligature_chars[c] || c.unicode_normalize(:nfkc) }
  end

  def gsub_sql(string, replacement)
    string = ApplicationRecord.connection.quote(string)
    replacement = ApplicationRecord.connection.quote(replacement)
    "regexp_replace(#{self}, #{string}, #{replacement}, 'g')"
  end

  def self.ligature_chars_regex
    @ligature_chars_regex ||= /[#{ligature_chars.keys.join('')}]/
  end

  def self.ligature_chars
    I18n::Backend::Transliterator::HashTransliterator::DEFAULT_APPROXIMATIONS
  end
end
