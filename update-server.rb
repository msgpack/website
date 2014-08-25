require 'sinatra'
require 'sinatra/streaming'
require_relative 'update-index'

set :server, 'puma'
set :port, (ENV['PORT'] || 8580).to_i

get '/update' do
  headers 'Content-Type' => 'text/plain'
  stream do |out|
    begin
      update_index(Logger.new(out))
    rescue => e
      out.puts e.to_s
      e.backtrace.each {|bt|
        out.write "  "
        out.puts bt
      }
    end
  end
end
