#require 'bunny'
require 'active_support'
require 'active-orient'
require 'yaml'
require_relative 'orientdb_time_graph'
#require 'dry/core/class_attributes'
#require_relative "logging"
require_relative "init_db"
	

module TG 

	## Standalone setup 
	##  
	## initializes ActiveOrient and adds time-graph database-classes
	## through namespace TG
	def self.setup environment = :test

	 project_root = File.expand_path('../..', __FILE__)
	 connect_file = project_root +'/config/connect.yml'

	 databaseyml   = YAML.load_file( connect_file )[:orientdb][:database]
	 admin_credentials = YAML.load_file(connect_file)[:orientdb][:admin]
	 logon =  { database: databaseyml[environment],
		 user: admin_credentials[:user],
		 password: admin_credentials[:pass],
		 server:  YAML.load_file( connect_file )[:orientdb][:server] }

	 ActiveOrient::Init.connect  logon
	 TG.connect logon
	 # we have to initialise the timegraph at this point, otherwise any
	 # manual requirement fails.
	 unless ActiveOrient::Model.namespace.send :const_defined?, 'Tag' 
		 Setup.init_database V.orientdb
	 end

	 ActiveOrient::Model.model_dir =  project_root + '/model'
	end



end
