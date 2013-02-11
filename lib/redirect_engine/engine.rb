require 'rubygems'
require 'bundler/setup'
require 'json'

class RedirectEngine::Engine

  $config = Hash.new

  def start()
    begin
      print "Hello from Engine\n"
    end
  end

  def redirect_for(sina, request, params)
    original_host = request.env["HTTP_X_FORWARDED_HOST"]
    write_log "=================== Redirecting for #{original_host} #{params[:query]}"
    write_log "Querystring = #{request.query_string}\n"

    redirect_config = get_redirect_config(original_host)

    write_log "Redirect Config = #{redirect_config}"
    return_code  = redirect_config["default"]["return_code"]
    redirect_url = redirect_config["default"]["target"]

    write_log "Redirecting #{params[:query]}\n"

    request_uri = "/#{params[:query]}"
    request_params = "#{request.query_string}"

    redirect_config["redirect"].each do |redirect|
      write_log "Checking regexp #{redirect['source']}"
      write_log "Request URI = #{request_uri}"
      if request_uri.match(redirect['source'])
        write_log "Hit!!"
        redirect_url = "http://#{original_host}#{redirect['target']}"
        return_code  = redirect["return_code"] if redirect["return_code"]
      end
    end

    write_log "Redirect to #{redirect_url}"
    sina.redirect redirect_url, return_code
    # return "Danke"
  end

  def get_config(host)
    get_redirect_config(host).to_json
  end

  def set_config(host, configuration)
    write_log "Setting config for host #{host} to \n#{configuration.to_json}"
    configuration.to_json
  end

# --- private functions ---
private

  def get_redirect_config(host)
    if ! $config[host]
      write_log "LOADING #{host}.yaml"
      $config[host] = load_yaml "#{host}.yaml"
    end
    $config[host]
  end

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

  def write_log(message)
    puts message
  end

end
