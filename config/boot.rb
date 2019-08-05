#  ########################  Outdated  ##################
#
#  do not use anymore
#
#  instead  
#  require  lib/setup 
#  and include 
#  TG.setup environment in the startup-script
#     with environment = :test, :development, :production
#  followed by
#  TG.connect
#
#
#
#
#
### Parameter: ARGV  (Array, argument from the command  line)
### t)test
### d)velopement
### p)roduction
###
### 

require 'bundler/setup'
require 'yaml'
require 'active-orient'
if RUBY_VERSION == 'java'
  require 'orientdb'
end
project_root = File.expand_path('../..', __FILE__)
require "#{project_root}/lib/orientdb_time_graph.rb"
begin
  connect_file = File.expand_path('../../config/connect.yml', __FILE__)
  config_file = File.expand_path('../../config/config.yml', __FILE__)
  connectyml  = YAML.load_file( connect_file )[:orientdb][:admin] if connect_file.present?
  configyml  = YAML.load_file( config_file )[:active_orient] if config_file.present?
rescue Errno::ENOENT => e
  ActiveOrient::Base.logger = Logger.new('/dev/stdout')
  ActiveOrient::OrientDB.logger.error{ "config/connectyml not present"  }
  ActiveOrient::OrientDB.logger.error{ "Using defaults to connect database-server"  }
end

e=  ARGV.present? ? ARGV.last.downcase : 'development'
env =  if e =~ /^p/
	 'production'
       elsif e =~ /^t/
	 'test'
       else
	 'development'
       end
puts "Using #{env}-environment"


# lib/init.rb

ActiveOrient::Model.model_dir =  "#{project_root}/#{ configyml.present? ? configyml[:model_dir] : "model" }"
puts "BOOT--> Project-Root:  #{project_root}"
puts "BOOT--> Model-dir:  #{ActiveOrient::Model.model_dir}"

databaseyml   = YAML.load_file( connect_file )[:orientdb][:database]
log_file =   if config_file.present?
	       dev = YAML.load_file( connect_file )[:orientdb][:logger]
	       if dev.blank? || dev== 'stdout'
		 '/dev/stdout'
	       else
		 project_root+'/log/'+env+'.log'
	       end
	     end


logger =  Logger.new log_file
logger.level = case env
	       when 'production' 
		 Logger::ERROR
	       when 'development'
		 Logger::WARN
	       else
		 Logger::INFO
	       end
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime("%d.%m.(%X)")}#{"%5s" % severity}->#{progname}:..:#{msg}\n"
end
ActiveOrient::Model.logger =  logger
ActiveOrient::OrientDB.logger =  logger
if connectyml.present? and connectyml[:user].present? and connectyml[:pass].present?
  ActiveOrient.default_server= { user: connectyml[:user], password: connectyml[:pass] ,
				 server: '172.28.50.25', port: 2480  }
  ActiveOrient.database = databaseyml[env.to_sym]
	ActiveOrient::Init.define_namespace  namespace: :object  
  ## Include customized NamingConvention for Edges
  ORD = ActiveOrient::OrientDB.new  preallocate: true 
  ORD.create_class 'E'
	ORD.create_class 'V'
  class E < ActiveOrient::Model
      def self.naming_convention name=nil
          name.present? ? name.upcase : ref_name.upcase
      end
  end

  TG.connect

  # load any unallocated database class, even it there is no model-file present
  ActiveOrient::Model.keep_models_without_file = true


  if RUBY_PLATFORM == 'java'
    DB =  ActiveOrient::API.new   preallocate: false
  else
    DB = ORD
  end

else
  ActiveOrient::OrientDB.logger = Logger.new('/dev/stdout')
  ActiveOrient::OrientDB.logger.error{ "config/connectyml is  misconfigurated" }
  ActiveOrient::OrientDB.logger.error{ "Database Server is NOT available"} 
end



