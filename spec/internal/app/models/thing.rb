class Thing
  include Circuit::Storage::MemoryModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity

  setup_attributes :id, :name
  attr_accessible :name

  validates :id, :name, :presence => true

  cattr_accessor :last_id do
    0
  end

  def initialize(opts={})
    memory_model_setup
    self.id = (self.last_id += 1)
    self.name = opts[:name]
  end

  if RUBY_VERSION =~ /^1\.8/
    # prevent Object#id will be deprecated; use Object#object_id warning
    def id(); attributes[:id]; end
  end

  def save
    return false if invalid?
    unless persisted?
      self.class.all << self
    end
    persisted!
  end

  def destroy
    return false unless persisted?
    self.class.all.delete(self)
    persisted!(false)
    return true
  end

  def assign_attributes(values, options = {})
    sanitize_for_mass_assignment(values, options[:as] || :default).each do |k, v|
      send("#{k}=", v)
    end
  end
end
