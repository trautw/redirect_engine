require 'redirect_engine/version'
require 'redirect_engine/engine'

# set :public_felder, File.dirname(__FILE__) + '/public'

# See http://www.sinatrarb.com/intro
# set :environment, :development
set :environment, :development
set :port, 80
# set :bind, "2001:6f8:966:ac10::106"
# set :bind, "ubuntu.chtw.de"
set :bind, "2001:470:1f15:5a8:20c:29ff:fe21:87aa"

engine = RedirectEngine::Engine.new
engine.start()

# See http://www.sinatrarb.com/intro
# set :environment, :development
set :environment, :development
set :port, 80
# set :bind, "2001:6f8:966:ac10::106"
# set :bind, "ubuntu.chtw.de"
set :bind, "2001:470:1f15:5a8:20c:29ff:fe21:87aa"

# ---------------------------------------------------
before do
  content_type :html, 'charset' => 'utf-8'
  # See http://rack.rubyforge.org/doc/classes/Rack/Request.html

  if request.env["HTTP_X_FORWARDED_HOST"]
    request.path_info = "/redirector#{request.path_info}"
  end
  # write_log "Querystring = #{request.query_string}\n"
  # write_log "Param source = #{request["source"]}\n"
  # http://stackoverflow.com/questions/6317705/rackrequest-how-do-i-get-all-headers
  # headers = env.select {|k,v| k.start_with? 'HTTP_'}
  # write_log "Headers = #{headers}\n"
  # write_log "Host = #{request.env["HTTP_HOST"]}\n"
  # write_log "Host = #{headers["HTTP_HOST"]}\n"
  # write_log "Original Host = #{request.env["HTTP_X_FORWARDED_HOST"]}\n"
end

after do
  puts "Response status = #{response.status}"
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/redirector/:query' do
  engine.redirect_for(self,  request, params)
end

get '/*' do
  # write_log "Error: Request doesn't match a valid route!"
  print "Error: Request #{params[:splat]} doesn't match a valid route!\n"
  return "@@ERROR@@" + "Error: Request doesn't match a valid route!\n"
end

module RedirectEngine
  # Your code goes here...
end
