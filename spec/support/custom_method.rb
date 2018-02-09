RSpec::Matchers.define :have_constant do |const, value|
  match do |owner|
   owner.const_defined?(const) &&  (owner.const_defined?(const).should eq (value))
  end
end

RSpec::Matchers.define :have_attr_accessor do |field|
  match do |object_instance|
    object_instance.respond_to?(field) &&
      object_instance.respond_to?("#{field}=")
  end
end

RSpec::Matchers.define :have_valid_string_enum do |field, values|
  match do |owner|
    eval("owner.#{field}").should eq (values.stringify_keys)
  end
end

RSpec::Matchers.define :have_encrypted_attribue do |attribute_name|
  encrypted_attribute = ('encrypted_' + attribute_name.to_s)
  match do |model|
     model.respond_to?(attribute_name) && model.respond_to?(encrypted_attribute.intern) && model.class.column_names.include?(encrypted_attribute)
  end
end
