class V

	# If the time_graph is used any Vertex class inherents the methods defined below. 
	#
	# Thus
	#
	#  if the vertices are connected via "...grid.." edges, they can be accessed by
	#  * next
	#  * prev
	#  * move( count  )
	#  * + (count)
	#  * - (count)
	#
  def next
		nodes( :out, via: /grid/ , expand: true).first
  end
  def prev
		nodes( :in, via: /grid/ , expand: true).first
  end
=begin
Moves horizontally within the grid
i.e
  the_day =  "4.8.2000".to_tg
  the_day.move(9).datum  # => "13.8.2000" 
  the_day.move(-9).datum # => "26.7.2000"
=end
  def move count
    dir =  count <0 ? :in : :out 
		edge_class = detect_edges( dir, /grid/, expand: false )
		q1 =  OrientSupport::OrientQuery.new( kind: :traverse )
		  .while( " $depth <= #{count.abs}")
			.from( self )
			.nodes( dir, via: edge_class, expand: false)
		
		q2= OrientSupport::OrientQuery.new from: q1, where: "$depth = #{count.abs} "
		r =  query q2


#    r= db.execute {  "select from ( traverse #{dir}(\"tg_grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth = #{count.abs} " }  
    if r.size == 1
      r.first
    else
      nil
    end
  end
=begin
Get the node (item) grids in the future

i.e.
  the_month =  TG::Jahr[2000].monat(8).pop
  the_month.value  # -> 8
  future_month = the_month + 6
  future_month.value # -> 2
=end
  def move_ item
    move item
  end
	alias :+ :move_
=begin
Get the node (item) grids in the past

i.e.
  the_day =  "4.8.2000".to_tg
  past_day = the_day - 6
  past_day.datum #  => "29.7.2000"
=end
  def move__ item
    move -item
  end
    
	alias :- :move__

# it is assumed, that any connection to the time-graph is done with an
# edge-class containing "has", ie: has_temperature, has_ohlc, has_an_appointment_with 
	def datum
		nodes( :in, via: /has/ ).first.datum
	end


	def to_tg
		nodes( :in, via: /has/ ).first
	end
end
