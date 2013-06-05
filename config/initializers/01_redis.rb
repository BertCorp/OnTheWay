ENV["REDISTOGO_URL"] ||= "localhost:6379"
#Rails.logger.info "REDISTOGO: #{ENV['REDISTOGO_URL'].inspect}"
uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
