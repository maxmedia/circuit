require "bundler/gem_tasks"
require "pathname"

$rake_root = Pathname(__FILE__).expand_path.dirname

Dir.glob($rake_root.join("**/*.rake").to_s).each do |fn|
  load fn
end

task :default => [:spec]

namespace :clobber do
  desc "Clobber Gem Package (pkg/)"
  task :pkg do
    $rake_root.join("pkg").rmtree rescue nil
  end

  desc "Clobber Coverage (coverage/)"
  task :coverage do
    $rake_root.join("coverage").rmtree rescue nil
  end

  task :doc => ["doc:clobber"]
end

desc "Clobber All"
task :clobber => ["doc:clobber", "clobber:pkg", "clobber:coverage"]
