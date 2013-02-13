require 'rubygems'
require 'bundler/setup'
require 'json'

class RedirectEngine::Engine

  $config = Hash.new
  $logger = nil

  def start()
    puts "puts: Hello from Engine\n"
  end

  def redirect_for(sina, request, params)
    original_host = request.env["HTTP_X_FORWARDED_HOST"]
    $logger.info "=================== Redirecting for #{original_host} #{params[:query]}"
    $logger.info "Querystring = #{request.query_string}\n"

    redirect_config = get_redirect_config(original_host)

    $logger.info "Redirect Config = #{redirect_config}"
    return_code  = redirect_config["default"]["return_code"]
    redirect_url = redirect_config["default"]["target"]

    $logger.info "Redirecting #{params[:query]}\n"

    request_uri = "/#{params[:query]}"
    request_params = "#{request.query_string}"

    redirect_config["redirect"].each do |redirect|
      $logger.info "Checking regexp #{redirect['source']}"
      $logger.info "Request URI = #{request_uri}"
      if request_uri.match(redirect['source'])
        $logger.info "Hit!!"
        redirect_url = "http://#{original_host}#{redirect['target']}"
        return_code  = redirect["return_code"] if redirect["return_code"]
      end
    end

    $logger.info "Redirect to #{redirect_url}"
    sina.redirect redirect_url, return_code
    # return "Danke"
  end

  def get_config(logger, host)
    $logger = logger
    get_redirect_config(host).to_json
  end

  def set_config(host, configuration)
    $logger.info "Setting config for host #{host} to \n#{configuration.to_json}"
    configuration.to_json
  end

# --- private functions ---
private

  def get_redirect_config(host)
    if ! $config[host]
      $logger.info "LOADING #{host}.yaml"
      $config[host] = load_yaml "#{host}.yaml"
    end
    $config[host]
  end

  def load_yaml(filename)
    if File.file? filename
        begin
          YAML::load_file(filename)
        rescue StringIndexOutOfBoundsException => e
          $logger.error "Error: YAML parsing in #{filename}"
          $logger.error "Error: YAML parsing in #{filename}"
          $logger.error e.message
          raise "YAML not parsable"
          false
        rescue Exception => e
          puts "Error: YAML parsing in #{filename}"
          $logger.error "Error: YAML parsing in #{filename}"
          $logger.error e.message
          raise "YAML not parsable"
          false
        end
    else
      raise "File not found: #{filename}"
    end
  end

  def write_log_disabled(message)
    $logger.info message
  end

end
