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
	## through namespace 
	# 
	# valid environments:  :test, :development, :production
	def self.setup environment = :test

		read_yml = -> (key) do
			YAML::load_file( File.expand_path('../../config/connect.yml',__FILE__))[key]
		end


	 logon =  read_yml[:orientdb][environment]

	 ActiveOrient::Init.connect  **logon
	 TG.connect **logon
	 # we have to initialise the timegraph at this point, otherwise any
	 # manual requirement fails.
	 unless ActiveOrient::Model.namespace.send :const_defined?, 'Tag' 
		 Setup.init_database V.orientdb
	 end

	end



end
