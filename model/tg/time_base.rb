class  TG::TimeBase # < V

=begin
Searches for specific value records 

Examples
  Monat[8]  --> Array of all August-month-records
  Jahr[1930 .. 1945]
=end
  def self.[] *key
#    result = OrientSupport::Array.new( work_on: self, 
#						work_with: db.execute{ "select from #{ref_name} #{db.compose_where( value: key.analyse)}" } )
 
		q= OrientSupport::OrientQuery.new where:{ value: key.analyse }
		result= query_database q
		result.size == 1 ? result.first : result # return object if only one record is fetched
  end

=begin
Get the node (item) grids in the future

i.e.
  the_month =  TG::Jahr[2000].monat(8).pop
  the_month.value  # -> 8
  future_month = the_month + 6
  future_month.value # -> 2
=end
  def + item
    move item
  end
=begin
Get the node (item) grids in the past

i.e.
  the_day =  "4.8.2000".to_tg
  past_day = the_day - 6
  past_day.datum #  => "29.7.2000"
=end
  def - item
    move -item
  end
    
=begin
Moves horizontally within the grid
i.e
  the_day =  "4.8.2000".to_tg
  the_day.move(9).datum  # => "13.8.2000" 
  the_day.move(-9).datum # => "26.7.2000"
=end
  def move count
    dir =  count <0 ? 'in' : 'out' 
    r= db.execute {  "select from ( traverse #{dir}(\"tg_grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth = #{count.abs} " }  
    if r.size == 1
      r.first
    else
      nil
    end
  end


  def analyse_key key    # :nodoc:

    new_key=  if key.first.is_a?(Range) 
			   key.first
			elsif key.size ==1
			 key.first
			else
			  key
			end
  end
=begin
Get the nearest horizontal neighbours

Takes one or two parameters. 

  (TG::TimeBase.instance).environment: count_of_previous_nodes, count_of_future_nodes

Default: return the previous and next 10 items

   "22.4.1967".to_tg.environment.datum
    => ["12.4.1967", "13.4.1967", "14.4.1967", "15.4.1967", "16.4.1967", "17.4.1967", "18.4.1967", "19.4.1967", "20.4.1967", "21.4.1967", "22.4.1967", "23.4.1967", "24.4.1967", "25.4.1967", "26.4.1967", "27.4.1967", "28.4.1967", "29.4.1967", "30.4.1967", "1.5.1967", "2.5.1967"]

It returns an array of TG::TimeBase-Objects



=end

  def environment previous_items = 10, next_items = nil
    next_items =  previous_items  if next_items.nil?  # default : symmetric fetching

    my_query =  -> (count) { dir =  count <0 ? 'in' : 'out';   db.execute {  "select from ( traverse #{dir}(\"tg_grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth >=1 " } }  # don't fetch self
    
   prev_result = previous_items.zero? ?  []  :  my_query[ -previous_items ] 
   next_result = next_items.zero? ?  []  : my_query[ next_items ] 

    prev_result.reverse  << self | next_result 
  end

=begin
Wrapper for 
  Edge.create in: self, out: a_vertex, attributes: { some_attributes on the edge }

  reloads the vertex after the assignment.
=end

  def assign vertex: , through: E , attributes: {}

    through.create from: self, to: vertex, attributes: attributes
    
    self.attributes = db.get_record( rid).attributes

  end


end
