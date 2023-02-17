require_relative "translatable_input"

class TranslatableStringInput < Formtastic::Inputs::StringInput
  include TranslatableInput
end
