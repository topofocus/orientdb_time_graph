# Execut with 
#  ActiveOrient::OrientSetup.init_database
#
module TG 
  module Setup
    def self.init_database database_instance
      dI = database_instance
      ActiveOrient::Init.define_namespace { TG }
      (logger= ActiveOrient::Base.logger).progname= 'OrientSetup#InitDatabase'
      vertexes =  dI.class_hierarchy base_class: 'time_base'
						# because edges are not resolved because of the namingconvention
      edges = dI.class_hierarchy base_class: 'E'
      logger.info{ " preallocated-database-classes: #{dI.database_classes.join(" , ")} " }

      delete_class = -> (c,d) do 
	the_class = ActiveOrient::Model.orientdb_class( name: c, superclass: d)
	logger.info{  "The Class: "+the_class.to_s+ " removed from Database" }
	the_class.delete_class
      end
      if defined?(TimeBase)
	vertexes.each{|v| delete_class[ v, :time_base ]}
	delete_class[ :time_base, :V ] 
	edges.each{|e| delete_class[ e, :E ] }
      end

      logger.info{ "  Creating Classes " }
      dI.create_classes 'E', 'V'
      #ActiveOrient::Init.vertex_and_egde_class
      dI.create_vertex_class :time_base		      # --> TimeBase
      # hour, day: month cannot be alloacated, because Day is a class of DateTime and thus reserved
      time_base_classes = dI.create_classes( :stunde, :tag, :monat, :jahr ){ TimeBase } # --> Hour, Day, Month
      TimeBase.create_property :value, type:  :integer 						
      #
      ## this puts an  index on child-classes
      time_base_classes.each{|c| c.create_index c.ref_name+'_value_idx' , type: :notunique, on: :value }
      
      # modified naming-convention in  model/e.rb
      edges = dI.create_edge_class :time_of, :day_of, :month_of, :grid_of	     # --> TIME_OF, :DAY_OF
      edges.each &:uniq_index

      dI.database_classes  # return_value
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
