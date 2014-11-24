require 'Capybara'
require 'Capybara/cucumber'
require 'rspec'
require 'capybara/poltergeist'

#Capybara.default_driver = :poltergeist
#Capybara.register_driver :poltergeist do |app|
#    options = {
#        :js_errors => true,
#        :timeout => 120,
#        :debug => false,
#        :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
#        :inspector => true,
#    }
#    Capybara::Poltergeist::Driver.new(app, options)
#end

Capybara.default_driver = :selenium

# Capybara.register_driver :chrome do |app|
#   Capybara::Selenium::Driver.new(app, :browser => :chrome)
# end

# Capybara.javascript_driver = :chrome