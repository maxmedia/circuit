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

  desc "Clobber combustion logs"
  task :combustion_logs do
    Pathname.glob($rake_root.join("spec", "internal", "log", "*.log")).each do |p|
      p.truncate(0) rescue nil
    end
  end
end

desc "Clobber All"
task :clobber => ["doc:clobber", "clobber:pkg", "clobber:coverage", "clobber:combustion_logs"]
