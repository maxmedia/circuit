require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => [:spec]

require "yard"
require "yard/rake/yardoc_task"

desc "Generate Yardoc documentation"
YARD::Rake::YardocTask.new do |yardoc|
  yardoc.name       = "doc"
  yardoc.options    = ["--verbose", "--markup", "markdown"]
  yardoc.files      = Dir[ *%w[lib/**/*.rb config.ru *file README.md LICENSE] ].tap do |a|
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
