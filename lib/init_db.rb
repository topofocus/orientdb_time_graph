module TG 
  module Setup
		def self.init_database database_instance= V.db
			stored_namespace =  ActiveOrient::Model.namespace
			ActiveOrient::Init.define_namespace { TG }
			(logger= ActiveOrient::OrientDB.logger).progname= 'TG::Setup#InitDatabase'
			# because edges are not resolved because of the namingconvention
			tg_edges =  [  :time_of, :day_of, :month_of, :grid_of ]	
			time_base_vertices =  [  :stunde, :tag, :monat, :jahr  ]
			edges = V.db.class_hierarchy( base_class: 'E') & tg_edges.map( &:to_s )
			vertices =  V.db.class_hierarchy( base_class: 'tg_time_base' ) & time_base_vertices.map( &:to_s )
			logger.info{ "affected-database-classes: \n #{ (vertices + edges).join(', ')}"  }

			delete_class = -> (c,d) do 
				the_class = ActiveOrient::Model.orientdb_class( name: c, superclass: d)
				logger.info{  "The Class: "+the_class.to_s+ " removed from Database" }
				the_class.delete_class
			end
			if defined?(TimeBase)
				vertices.each{|v| delete_class[ v, :tg_time_base ] }
				delete_class[ :tg_time_base, :V ] 
			end

      logger.progname= 'TG::Setup#InitDatabase'
      cleared_database = V.db.database_classes 
      logger.info{ "  Creating Classes " }
      V.create_class :time_base		      # --> TimeBase
      # hour, day: month cannot be alloacated, because Day is a class of DateTime and thus is reserved
      time_base_classes = TimeBase.create_class *time_base_vertices  # --> Hour, Day, Month
      TimeBase.create_property :value, type:  :integer 						
      #
      ## this puts an  index on child-classes
      time_base_classes.each{|c| c.create_index c.ref_name+'_value_idx' , type: :notunique, on: :value }
      
      # modified naming-convention in  model/e.rb
      edges = E.create_class  *tg_edges   # --> TIME_OF, :DAY_OF
      edges.each &:uniq_index

      # restore namespace
      ActiveOrient::Init.define_namespace { stored_namespace }

      V.db.database_classes - cleared_database  # return_value
    end
  end
end
# to_do:  define validations
#  hour_class   = r.create_vertex_class "Hour", properties: {value_string: {type: :string}, value: {type: :integer}}
#  hour_class.alter_property property: "value", attribute: "MIN", alteration: 0
#  hour_class.alter_property property: "value", attribute: "MAX", alteration: 23
#
#  day_class    = r.create_vertex_class "Day", properties: {value_string: {type: :string}, value: {type: :integer}}
#  day_class.alter_property property: "value", attribute: "MIN", alteration: 1
#  day_class.alter_property property: "value", attribute: "MAX", alteration: 31
#
#  month_class  = r.create_vertex_class "Month", properties: {value_string: {type: :string}, value: {type: :integer}}
#  month_class.alter_property property: "value", attribute: "MIN", alteration: 1
#  month_class.alter_property property: "value", attribute: "MAX", alteration: 12
#

#  timeof_class = r.create_edge_class "TIMEOF"
