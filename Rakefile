require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => [:spec]

require "yard"
require "yard/rake/yardoc_task"

desc "Generate Yardoc documentation"
YARD::Rake::YardocTask.new do |yardoc|
  yardoc.name       = "doc"
  yardoc.files      = Dir[ *%w[lib/**/*.rb config.ru *file] ].tap do |a|
                        a.delete_if {|fn| File.basename(fn) =~ /^\./}
                      end
end

namespace :clobber do
  desc "Clobber Gem Package (pkg/)"
  task :pkg do
    FileUtils.rm_rf("pkg")
  end

  desc "Clobber Coverage (coverage/)"
  task :coverage do
    FileUtils.rm_rf("coverage")
  end

  desc "Clobber Yardocs (doc/ and .yardoc/)"
  task :doc do
    FileUtils.rm_rf("doc")
    FileUtils.rm_rf(".yardoc")
  end
end

desc "Clobber All"
task :clobber => ["clobber:doc", "clobber:pkg", "clobber:coverage"]

desc "Generate gemfiles for Travis-ci"
task "generate-gemfiles" do
  definition = Bundler::Dsl.new
  definition.instance_eval(Bundler.read_file("Gemfile"), "Gemfile", 1)

  # No-mongo
  File.open(File.join("gemfiles", "no-mongo.gemfile"), "w") do |f|
    f.puts %(source "http://rubygems.org")

    definition.dependencies.each do |dep|
      next if dep.groups == [:default]
      next if dep.groups.include?(:mongo)

      ln = %(gem "%s", "%s")%[dep.name, dep.requirement]
      ln << %(, group: [) << dep.groups.collect {|v| %(:#{v})}.join(", ") << %(])
      if dep.autorequire == []
        ln << %(, require: false)
      elsif dep.autorequire
        ln << %(, require: [)
        ln << dep.autorequire.collect {|s| ln << %("#{s}")}.join(",")
        ln << %(])
      end
      if dep.source and dep.source.is_a?(Bundler::Source::Git)
        ln << %(, git: "%s", branch: "%s")%[dep.source.options["git"], dep.source.options["branch"]]
      elsif dep.source
        raise "Unknown source type: %s"%[dep.source.class]
      end
      f.puts ln
    end

    f.puts %(gemspec path: "../")
  end

  # Rails 3.1
  File.open(File.join("gemfiles", "rails31.gemfile"), "w") do |f|
    f.puts %(source "http://rubygems.org")

    definition.dependencies.each do |dep|
      next if dep.groups == [:default]

      ln = %(gem "%s", "%s")%[dep.name, dep.requirement]
      ln << %(, group: [) << dep.groups.collect {|v| %(:#{v})}.join(", ") << %(])
      if dep.autorequire == []
        ln << %(, require: false)
      elsif dep.autorequire
        ln << %(, require: [)
        ln << dep.autorequire.collect {|s| %("#{s}")}.join(",")
        ln << %(])
      end
      if dep.source and dep.source.is_a?(Bundler::Source::Git)
        ln << %(, git: "%s", branch: "%s")%[dep.source.options["git"], dep.source.options["branch"]]
      elsif dep.source
        raise "Unknown source type: %s"%[dep.source.class]
      end
      f.puts ln
    end

    f.puts %(gem "activesupport", "~> 3.1.0")
    f.puts %(gem "activemodel", "~> 3.1.0")
    f.puts %(gem "rails", "~> 3.1.0", group: [:development, :test])

    f.puts %(gemspec path: "../")
  end
  puts "Done."
end