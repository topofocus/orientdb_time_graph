require 'active-orient'
require_relative 'time_graph.rb'
require_relative '../config/init_db'



module TG

  def self.set_defaults  login =  nil
    c = { :server => 'localhost',
	  :port   => 2480,
	  :protocol => 'http',
	  :user    => 'root',
	  :password => 'root',
	  :database => 'temp'
    }.merge login.presence || {}

    ActiveOrient.default_server= { user: c[:user], password: c[:password] ,
				   server: c[:server], port: c[:port]  }
    ActiveOrient.database = c[:database]
    logger =  Logger.new '/dev/stdout'
    ActiveOrient::Base.logger =  logger 
    ActiveOrient::OrientDB.logger = logger 
  end
  def self.connect login =  nil
    project_root = File.expand_path('../..', __FILE__)

    set_defaults(login) if ActiveOrient::Base.logger.nil? 
    ActiveOrient::Init.define_namespace { TG } 
    ActiveOrient::Model.model_dir =  "#{project_root}/model"
    ActiveOrient::OrientDB.new  preallocate: true  # connect via http-rest
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
    puts TG::Jahr.all.value.sort.join('; ')
    puts ""
    puts "Type: #{TG::Stunde.all.empty? ? "Date-Graph" : "DateTime-Graph"}"
    puts ""

  end
end





