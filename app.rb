require 'erb'
require 'pstore'

$list = Hash.new(0)
require 'bundler'
Bundler.require

# data model
$list['yield_self'] = 0


class ResultServer < Sinatra::Base
  get '/' do
    @list = $list
    erb :index
  end

  post '/' do
    name = params[:name]
    name = params[:other] if name == '_another_idea'

    escaped_name = Rack::Utils.escape_html(name)

    if name != escaped_name
      status = 400
      body "unacceptable method name: #{escaped_name.inspect}"
    else
      $list[escaped_name] += 1
      @message = "#{escaped_name}++"
      @list = $list
      erb :index
    end
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end
