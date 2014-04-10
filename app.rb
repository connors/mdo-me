require 'rubygems'
require 'sinatra'
require 'open-uri'
require_relative 'lib/mdo-me.rb'

class MdoMeApp < Sinatra::Application
  configure do
    `mkdir -p #{Dir.pwd}/tmp`
  end

  get '/' do
    begin
      # Get the unescaped 'url' param
      match = env['REQUEST_URI'].match(/url=([^&]*)/)
      url = match && match[1]

      unless url
        content_type :text
        return "You need to pass a URL. http://#{request.host}/?url=YOUR_PHOTO_URL"
      end

      # Ok, it's jpg
      content_type 'image/jpg'

      # Get the filename
      filename = File.basename(url)

      # Maybe we have it already
      if result = MdoMe.already_correct(filename)
        return File.read result
      end

      # Download the new file
      puts `curl -v -o "#{Dir.pwd}/tmp/#{File.basename(url)}" "#{url}"`

      File.read MdoMe.lean_into_it File.join(Dir.pwd, 'tmp', filename)
    rescue => e
      p e
      redirect 'http://blog.teamtreehouse.com/wp-content/uploads/2012/01/Bootstrap-from-Twitter.jpg'
    end
  end

  get '/stats' do
    content_type :text
    `ls -l tmp/*-result/* | wc -l`.strip
  end
end
