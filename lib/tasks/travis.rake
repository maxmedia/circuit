class TravisCiGemfileGenerator
  def initialize(gemfile)
    @definition = Bundler::Dsl.new
    @definition.instance_eval(Bundler.read_file(gemfile), "Gemfile", 1)
  end

  def generate(filename, options={})
    File.open(filename, "w") do |f|
      f.puts %(source "http://rubygems.org")

      @definition.dependencies.each do |dep|
        next if exclude_by_group?(dep, :default, options[:without])
        f.puts dependency_line(dep)
      end

      case options[:add]
      when String
        f.puts options[:add]
      when Array
        options[:add].each {|ln| f.puts ln}
      else
        raise "Invalid :add option: %p"%[options[:add]] if options[:add]
      end

      f.puts %(gemspec :path => "../")
    end
  end

  private

  def dependency_line(dep)
    ln = [ %(gem "%s")%[dep.name] ]

    ln << %("%s")%[dep.requirement]

    groups = dep.groups.collect {|v| %(:#{v})}.join(", ")
    ln << %(:group => [%s])%[groups]

    if dep.autorequire == []
      ln << %(:require => false)
    elsif dep.autorequire
      requires = dep.autorequire.collect {|s| %("#{s}")}.join(",")
      ln << %(:require => [%s])%[requires]
    end

    if dep.source and dep.source.is_a?(Bundler::Source::Git)
      ln << %(:git => "%s")%[dep.source.options["git"]]
      ln << %(:branch => "%s")%[dep.source.options["branch"]]
    elsif dep.source
      raise "Unknown source type: %s"%[dep.source.class]
    end

    ln.join(", ")
  end

  def exclude_by_group?(dep, *without)
    return false if without.nil? or without.empty?
    without = without.compact.flatten
    !(dep.groups & without).empty?
  end
end

namespace :travis do
  desc "Generate gemfiles for Travis-ci"
  task :gemfiles do
    gen = TravisCiGemfileGenerator.new($rake_root.join("Gemfile").to_s)

    # No Mongo
    gen.generate($rake_root.join("gemfiles", "no-mongo.gemfile").to_s,
                 :without => [:mongo])

    # Rails 3.1
    gen.generate($rake_root.join("gemfiles", "rails31.gemfile").to_s,
                 :add => [ %(gem "activesupport", "~> 3.1.0"),
                           %(gem "activemodel", "~> 3.1.0"),
                           %(gem "rails", "~> 3.1.0", :group => [:development, :test]) ])

    puts "Done."
  end
end
