require 'erb'
require 'yaml/store'

require 'bundler'
Bundler.require

DB = YAML::Store.new('vote_result.yaml')
def vote_results
  results = DB.transaction{|db| db['result']}
  results || %w(yield_self then transform apply do to l I map change alter yield in morph adopt alt tweak as).each_with_object({}){|e, r| r[e] = 0}
end

def update_vote_results name, val
  DB.transaction{|db|
    result = db['result'] || {}
    result[name] = val
    db['result'] = result
  }
end

class ResultServer < Sinatra::Base
  get '/' do
    @list = vote_results
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
      @message = "#{escaped_name}++"
      val = vote_results[escaped_name] || 0
      @list = update_vote_results(escaped_name, val+1)
      erb :index
    end
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end
