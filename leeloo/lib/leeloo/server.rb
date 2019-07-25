require 'webrick'
require 'json'
require 'base64'

class Server

    def start preferences
        server = WEBrick::HTTPServer.new :Port => 8000
        server.mount_proc '/' do |req, res|
            query = req.query()["q"] || req.body()
            if query
                begin
                    body = JSON.parse(Base64.strict_decode64 query)
                    key = body["body"] ? JSON.parse(body["body"]) : body
                    res.body = preferences.keystore(key["keystore"]).secret_from_footprint(key).read.to_s
                rescue => exception
                    puts exception
                    res.status = 400
                end
            else
                res.status = 400
            end
        end

        trap 'INT' do server.shutdown end
        server.start
    end
end
