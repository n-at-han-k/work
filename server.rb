require "json"
require "openssl"
require "securerandom"

require "sequel"
require "async/http/internet"
require "ratalada/async"

HOST = ENV.fetch("HOST", "0.0.0.0")
PORT = ENV.fetch("PORT", "3335")


Server.run(host: HOST, port: PORT) do |request|

end
