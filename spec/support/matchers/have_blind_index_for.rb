RSpec::Matchers.define :have_blind_index_for do |attribute|

  chain :test_with_query do |query|
    @query = query
  end

  chain :matching do |*terms|
    @terms = terms
  end

  chain :but_not do |*other_terms|
    @other_terms = other_terms
  end

  match do |subject|
    @failed = []

    subject.save!

    # make sure the dedicated column exists
    column_name = attribute.to_s + "_bidx"
    unless subject.class.column_names.include?(column_name)
      @failed << "missing column"
    end
    unless subject.class.columns.find { |c| c.name == column_name }.type == :string
      @failed << "wrong column type"
    end

    # make sure the saved content is hashed
    subject.assign_attributes(attribute => @terms.first)
    unless subject.send(attribute) == @terms.first
      @failed << "could not assign test value"
    end
    if subject.send(column_name).nil? || subject.send(column_name) == @terms.first
      @failed << "test value was not hashed"
    end

    # search: matching
    query_bidx = subject.class.send("generate_#{attribute}_bidx", @query)
    @terms.each do |term|
      subject.update!(attribute => term)
      if subject.class.find_by(column_name => query_bidx) != subject
        @failed << "didnt find the subject with value #{term} while querying for #{@query}"
      end
      if subject.class.ransack("#{attribute}_eq" => @query).result.first != subject
        @failed << "didnt find the subject with value #{term} while querying for #{@query}, using ransacker"
      end
    end

    # search: non-matching
    query_bidx = subject.class.send("generate_#{attribute}_bidx", @query)
    @other_terms.each do |term|
      subject.update!(attribute => term)
      if subject.class.find_by(column_name => query_bidx) == subject
        @failed << "found the subject with value #{term} while querying for #{@query}"
      end
      unless subject.class.ransack("#{attribute}_eq" => @query).result.first.nil?
        @failed << "found the subject with value #{term} while querying for #{@query}, using ransacker"
      end
    end

    @failed.empty?
  end

  failure_message do |subject|
    message = "#{subject.class.name}.#{attribute} doesn't seem to have proper blind index:"
    @failed.each do |failure|
      message << "\n - #{failure}"
    end
    message
  end
end
