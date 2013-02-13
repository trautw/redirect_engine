require 'redirect_engine/engine'

require 'webrick'
require 'webrick/https'

use Rack::Logger

set :run, false

module Support

  $engine = nil
  $engine_config = nil
  $logger = nil

  class MyServer  < Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    # --- private functions ---
    private

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
      # puts "Response status = #{response.status}"
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get '/redirector/:query' do
      $engine.redirect_for(self,  request, params)
    end

    # e.g. http://ubutu.chtw.de/config/trautwein.homeip.net
    get '/config/:host' do
      headers "Access-Control-Allow-Origin" => $engine_config["allow_origin"]
      # $logger.info("KHJKHJKHKJHKJH")
      # $logger.error("cwmbmnbmnbmnbmnbmbmnb")
      # $logger.debug("GGGGGGGGGGGGGGGGGGGG")
      $engine.get_config($logger,params[:host])
    end
    
    # e.g. http://ubutu.chtw.de/config/trautwein.hoeip.net
    post '/config/:host' do
      headers "Access-Control-Allow-Origin" => "http://ubuntu.chtw.de:4567"
      $engine.set_config(params[:host], params[:json])
    end
    
    get '/*' do
      # write_log "Error: Request doesn't match a valid route!"
      $logger.error "Error: Request #{params[:splat]} doesn't match a valid route!\n"
      return "@@ERROR@@" + "Error: Request doesn't match a valid route!\n"
    end
    
  end


  class ServerInitializer
    def initialize(config_file)
      puts "Initializing Server from #{config_file}"
      $engine_config = load_yaml(config_file)
      $logger = WEBrick::Log::new($engine_config["logfile"], WEBrick::Log::DEBUG)

      $engine = RedirectEngine::Engine.new
      $engine.start()

      access_log_stream = File.open($engine_config["access_log"], 'w')
      access_log = [ [ access_log_stream, WEBrick::AccessLog::COMBINED_LOG_FORMAT ] ]

      webrick_options = {
        :Port               => $engine_config["port"] || 8443,
        :Host               => $engine_config["ip"] || "127.0.0.1",
      #  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :Logger             => $logger,
        :AccessLog          => access_log,
        :DocumentRoot       => File.dirname(__FILE__) + '/../public',
        :SSLEnable          => true,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join($engine_config["cert_path"], $engine_config["hostname"] + ".cert")).read),
        :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join($engine_config["cert_path"], $engine_config["hostname"] + ".key")).read),
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
        :app                => MyServer
      }

      Rack::Server.start webrick_options

    end

    private
    def load_yaml(filename)
      if File.file? filename
          begin
            YAML::load_file(filename)
          rescue StringIndexOutOfBoundsException => e
            puts "Error: YAML parsing in #{filename}"
            write_log "Error: YAML parsing in #{filename}"
            write_log e.message
            raise "YAML not parsable"
            false
          rescue Exception => e
            puts "Error: YAML parsing in #{filename}"
            write_log "Error: YAML parsing in #{filename}"
            write_log e.message
            raise "YAML not parsable"
            false
          end
      else
        raise "File not found: #{filename}"
      end
    end

    def write_log_disabled(message)
      # logger.info(message)
      # puts message
      $logger.info(message)
    end

  end

end

