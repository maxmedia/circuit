require "yard"
require "yard/rake/yardoc_task"
require "dionysus/redcarpet/includes"

namespace :doc do
  YARD::Rake::YardocTask.new do |yardoc|
    yardoc.files      = Dir[ *%w[lib/**/*.rb config.ru *file] ].tap do |a|
                          a.delete_if {|fn| File.basename(fn) =~ /^\./}
                        end
  end

  desc "Clobber Yardocs (doc/ and .yardoc/)"
  task :clobber do
    $rake_root.join("doc").rmtree rescue nil
    $rake_root.join(".yardoc").rmtree rescue nil
  end
end

desc "Generate Yardoc documentation"
task :doc => ["doc:yard"]
