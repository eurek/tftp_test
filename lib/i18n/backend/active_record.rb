require "i18n/backend/base"

# heavily inspired from https://github.com/svenfuchs/i18n-active_record/, but adapted to work nicely with Mobility
module I18n
  module Backend
    class ActiveRecord
      module Implementation
        include Base
        include Flatten

        def available_locales
          ::Translation.available_locales
        end

        def store_translations(locale, data, options = {})
          escape = options.fetch(:escape, true)
          create_only = options.fetch(:create_only, false)

          Translation.transaction do
            flatten_translations(locale, data, escape, false).each do |key, value|
              # cleanup conflicts, e.g.: can't have "common.actions" defined if "common.actions.new" is being written...
              conflicting_translations = ::Translation.where(key: conflicting_keys(key))
              conflicting_translations.destroy_all

              # ... and vice versa
              conflicting_translations = ::Translation.where("key LIKE ?", key.to_s + ".%")
              conflicting_translations.destroy_all

              # create new translation
              translation = ::Translation.find_or_initialize_by(key: key)
              next if create_only && translation.value(locale: locale, fallback: false).present?

              I18n.with_locale(locale) do
                translation.update(value: value)
              end
            end
          end

          reload!
        end

        def reload!
          @translations = nil
          self
        end

        def initialized?
          !@translations.nil?
        end

        def init_translations
          @translations = if Translation.table_exists?
            ::Translation.to_hash
          else
            {}
          end
        end

        def translations(do_init: false)
          init_translations if do_init || !initialized?
          @translations ||= {}
        end

        protected

        def lookup(locale, key, scope = [], options = EMPTY_HASH)
          # flatten the key, e.g.: key="actions.new", scope=["common"] => common.actions.new
          key = normalize_flat_keys(locale, key, scope, options[:separator])

          # remove leading and trailing dots
          key = key.delete_prefix(".").delete_suffix(".")

          # fetch results
          keys = [locale.to_sym] + key.split(I18n::Backend::Flatten::FLATTEN_SEPARATOR).map(&:to_sym)
          translations.dig(*keys)
        end

        # For a key :'foo.bar.baz' return ['foo', 'foo.bar', 'foo.bar.baz']
        def expand_keys(key)
          key.to_s.split(FLATTEN_SEPARATOR).inject([]) do |keys, key|
            keys << [keys.last, key].compact.join(FLATTEN_SEPARATOR)
          end
        end

        def conflicting_keys(key)
          expand_keys(key) - [key.to_s]
        end
      end

      include Implementation
    end
  end
end
