require 'dionysus/travisci/gemfile_generator'

namespace :travis do
  desc "Generate gemfiles for Travis-ci"
  task :gemfiles do
    gen = Dionysus::TravisCI::GemfileGenerator.new($rake_root.join("Gemfile").to_s)

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
