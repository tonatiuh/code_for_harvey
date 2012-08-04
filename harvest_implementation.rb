require "base64"
require "bigdecimal"
require "date"
require "time"
require "net/http"
require "net/https"
require "json"

ACCOUNT_EMAIL    =  ''
ACCOUNT_PASSWORD =  ''

class Harvest
	
	def initialize
		connect
	end

	def auth_string
		Base64.encode64("#{ACCOUNT_EMAIL}:#{ACCOUNT_PASSWORD}")
	end

	def headers
		{
			"Accept"	=>	"application/json",
			"Content-Type"	=>	"application/json; charset=utf-8",
			"Authorization"	=> "Basic #{auth_string}"
		}
	end

	def connect
		port =  443
		@connection = Net::HTTP.new("tangosource.harvestapp.com", port)
		@connection.use_ssl = true 
	end

	def request path, method = :get
		response = @connection.get(path, headers)
	end

end

harvy = Harvest.new
response = harvy.request '/daily', :get
result = JSON.parse response.body
total_hours = 0

puts ""
printf "%20s %20s %20s %50s %20s \n", "CLIENT", "PROJECT", "TASK", "NOTES", "HOURS"
puts ""
result["day_entries"].each do |entry|
	printf "%20s %20s %20s %50s %20s \n",  entry["client"], entry["project"], entry["task"], entry["notes"].split[0..4].join(" ") + "...", entry["hours"]
	total_hours += entry["hours"].to_f
end
printf "%20s %20s %20s %50s %20s \n", "", "", "", "", "Total: #{total_hours}"
