RSpec::Matchers.define :have_module do |mod_or_name|
  match do |obj|
    !!obj.included_modules.detect { |m| m.to_s == mod_or_name.to_s }
  end

  failure_message_for_should do |obj|
    "expected %p with modules %p to include module '%s'"%[obj, obj.included_modules, mod_or_name]
  end

  failure_message_for_should_not do |obj|
    "expected %p with modules %p to not include module '%s'"%[obj, obj.included_modules, mod_or_name]
  end
end
