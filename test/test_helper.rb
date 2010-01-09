
require 'rubygems'
require 'shoulda'
require 'yaml'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'muddyit_fu'

class Test::Unit::TestCase
  # Add more helper methods to be used by all tests here...

  def load_config(file = 'config.yml')
    f = File.dirname(__FILE__) + '/../test/' + file
    unless File.exist?(f)
      puts "Unable to find configuration file #{f}"
      exit 1
    end
    open(f) {|file| YAML.load(file) }
  end

end
