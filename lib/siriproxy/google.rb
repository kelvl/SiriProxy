require 'uri'
require 'net/http'
require 'pp'
require 'json'
require './speexext/speexdec'

class SiriProxy::Google
	class << self
	
		def speech_recognize(hexData)
			dec = Speexdec.new()
			
			hexArr = hexData.split("\n")
			
			encoded = ""
			
			hexArr.each { |e| 
				dec.transcode(e).each { |d| 
					encoded << d
				} 
			}
			
			url = URI.parse('http://www.google.com')
			
			http = Net::HTTP.new(url.host, url.port)
			
			request = Net::HTTP::Post.new('/speech-api/v1/recognize?client=chromium&pfilter=2&lang=en-US&maxresults=6', {"Content-Type" => "audio/x-speex-with-header-byte; rate=16000"});
			
			request.body = encoded
			
			request.inspect
			
			response = http.request(request)
			
			json = JSON.parse(response.body())
			
			pp json
			
			return json["hypotheses"][0]
		
		end
		
		def speech_recognize2(hexData)
			encoderBinary = "./hex"

			io = IO.popen("#{encoderBinary} 2>/dev/null", "w+");
			
			io.puts(hexData)
			
			io.close_write
			
			encoded = io.read()
			
			io.close
			
			url = URI.parse('http://www.google.com')
			
			http = Net::HTTP.new(url.host, url.port)
			
			request = Net::HTTP::Post.new('/speech-api/v1/recognize?client=chromium&pfilter=2&lang=en-US&maxresults=6', {"Content-Type" => "audio/x-speex-with-header-byte; rate=16000"});
			
			request.body = encoded
			
			request.inspect
			
			response = http.request(request)
			
			json = JSON.parse(response.body())
			
			return json["hypotheses"][0]
					
		end
	end
end