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

    my_query =  -> (count) do
			dir =  count <0 ? 'in' : 'out'   
			db.execute {  "select from ( traverse #{dir}(\"tg_grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth >=1 " }   # don't fetch self and return an Array
		end
   prev_result = previous_items.zero? ?  []  :  my_query[ -previous_items.abs ] 
   next_result = next_items.zero? ?  []  : my_query[ next_items.abs ] 
   # return a collection suitable for further operations
   OrientSupport::Array.new work_on: self, work_with: (prev_result.reverse <<  self  | next_result )

  end


end
