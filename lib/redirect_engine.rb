require 'redirect_engine/version'
require 'redirect_engine/support'

module RedirectEngine
  
  rc_file = File.join(ENV["HOME"] , ".redirect_engine.yaml")
  Support::ServerInitializer.new(rc_file)

end
