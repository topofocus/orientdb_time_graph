require 'active-orient'
require_relative 'time_graph.rb'
require_relative 'support.rb'

require_relative 'init_db'



module TG

	# completes the parameter for calling ActiveOrient::Init.connect
	# 
	# Is called from connect only if ActiveOrient.default_server is not set previously
	# 
	# otherwise the credentials from the main-activeorient-instance are used.
  def self.set_defaults  login =  nil
    c = { :server =>  'localhost',
	  :port   => 2480,
	  :protocol => 'http',
	  :user    => 'root',
	  :password => 'root',
	  :database => 'temp'
    }.merge login.presence || {}

    ActiveOrient.default_server= { user: c[:user], password: c[:password] ,
				   server: c[:server], port: c[:port]  }
    ActiveOrient.database = c[:database]
  end


  def self.info 
    puts "-------------- TIME GRAPH ------------------"
    puts "Allocated Years : "
    puts TG::Jahr.all.map(&:value).sort.join('; ')
    puts ""
    puts "Type: #{TG::Stunde.all.empty? ? "Date-Graph" : "DateTime-Graph"}"
    puts ""

  end
end





