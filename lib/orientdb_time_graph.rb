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
  def self.set_defaults  **login
    c = { :server =>  'localhost',
	  :port   => 2480,
	  :protocol => 'http',
	  :user    => 'root',
	  :password => 'root',
	  :database => 'temp'
    }.merge login

    ActiveOrient.default_server= { user: c[:user], password: c[:password] ,
				   server: c[:server], port: c[:port]  }
    ActiveOrient.database = c[:database]
  end

  def self.connect **login
    project_root = File.expand_path('../..', __FILE__)
    set_defaults( **login) unless ActiveOrient.default_server.is_a?(Hash) && ActiveOrient.default_server[:user].present?
    ActiveOrient::Init.define_namespace { TG } 
		# a provided block is used to introduce additional locations of model-files
		the_model_dirs = block_given? ? [ "#{project_root}/model", yield].flatten :  [ "#{project_root}/model" ]
		ActiveOrient::OrientDB.new  preallocate: true, model_dir: the_model_dirs
		@time_graph = TG.const_defined?(:TIME_OF) ? TG::TIME_OF.count > 0 : nil
  end

	def self.time_graph?
		@time_graph
	end
  def self.check_and_initialize database_instance
    if database_instance.get_classes( "name").values.flatten.include? 'time_base'
      return true
    else
      TG::Setup.init_database database_instance
      puts "Database-Structure allocated"
      puts "Exiting now, please restart and call »TG::TimeGraph.populate«"
      Kernel.exit
    end
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





