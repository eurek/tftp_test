require_relative "translatable_input"

class TranslatableTextInput < Formtastic::Inputs::TextInput
  include TranslatableInput
end
