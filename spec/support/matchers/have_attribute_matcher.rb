RSpec::Matchers.define :have_attribute do |attribute|
  match do |model|
    if model.respond_to?(attribute) and model.respond_to?("#{attribute}=")
      obj = Object.new
      old = model.send(attribute)
      model.send("#{attribute}=", obj)
      result = (model.attributes[attribute] == obj)
      model.send("#{attribute}=", old)
      result
    else
      false
    end
  end

  failure_message_for_should do |model|
    "#{model.class} should have attribute accessor #{attribute.inspect}"
  end

  failure_message_for_should_not do |model|
    "#{model.class} should not have attribute accessor #{attribute.inspect}"
  end
end
