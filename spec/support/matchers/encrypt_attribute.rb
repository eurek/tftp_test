RSpec::Matchers.define :encrypt_attribute do |attribute|

  chain :sample_value do |sample_value|
    @sample_value = sample_value
  end

  match do |subject|
    @sample_value = "test" if @sample_value.nil?

    @failed = []

    subject.save!

    # make sure the dedicated column exists
    column_name = attribute.to_s + "_ciphertext"
    unless subject.class.column_names.include?(column_name)
      @failed << "missing column"
    end
    unless subject.class.columns.find { |c| c.name == column_name }.type == :text
      @failed << "wrong column type"
    end

    # make sure the saved content is encrypted
    subject.assign_attributes(attribute => @sample_value)
    unless subject.send(attribute) == @sample_value
      @failed << "could not assign test value"
    end
    if subject.send(column_name).nil? || subject.send(column_name) == @sample_value
      @failed << "test value was not encrypted"
    end

    @failed.empty?
  end

  failure_message do |subject|
    message = "#{subject.class.name}.#{attribute} doesn't seem to be properly encrypted:"
    @failed.each do |failure|
      message << "\n - #{failure}"
    end
    message
  end
end
