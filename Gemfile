source "http://rubygems.org"

group :development, :test do
  gem "rake",               "~> 0.9.2"
  gem "combustion",         "= 0.3.1"
  gem "rspec-rails",        "~> 2.6.1"
  gem "shoulda-matchers",   "~> 1.1.0"
  gem "database_cleaner",   "~> 0.7.2"
  gem "capybara",           "~> 1.1.2"
  gem "mocha",              "~> 0.11.4"
  gem "rspec-rails-mocha",  "~> 0.3.2"
  gem "delorean",           "~> 1.2.0"
  gem "machinist",          "~> 2.0.0.beta2"
  gem "faker",              "~> 1.0.1"
  gem "simplecov",          "~> 0.6.4", require: false

  # Hack to prevent infinite loop in bundler's dependency resolution
  gem "thor",               "< 0.15"
end

group :development do
  gem "yard",               "~> 0.8"
  gem "redcarpet",          "~> 2.1"
end

group :mongo do
  gem "mongoid",            "~> 2.4"
  gem "mongoid-tree",       "~> 0.7"
  gem "bson_ext",           "~> 1.4"
  gem "mongoid-rspec",      "= 1.4.4"
  gem "machinist_mongo",
      require: "machinist/mongoid",
      git: "git://github.com/nmerouze/machinist_mongo.git",
      branch: "machinist2"
end

# Specify core dependencies in core.gemspec
gemspec
