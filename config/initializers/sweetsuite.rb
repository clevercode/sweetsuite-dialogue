require 'yaml'

begin
  configuration = YAML.load_file(Rails.root.join('config','sweetsuite.yml'))
  configuration = configuration[Rails.env]
  configuration = HashWithIndifferentAccess.new(configuration)
  SweetSuite.config.update(configuration)

rescue LoadError
  puts "The /config/sweetsuite.yml file is missing or broken"
end
