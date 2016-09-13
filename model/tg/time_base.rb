class  TG::TimeBase < V

=begin
Searches for specific value records 

Examples
  Monat[8]  --> Array of all August-month-records
  Jahr[1930 .. 1945]
=end
  def self.[] *key
    result = OrientSupport::Array.new( work_on: self, work_with: db.execute{ "select from #{ref_name} #{db.compose_where( value: key.analyse)}" } )
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
Moves vertically within the grid
i.e
  the_day =  "4.8.2000".to_tg
  the_day.move(9).datum  # => "13.8.2000" 
  the_day.move(-9).datum # => "26.7.2000"
=end
  def move count
    dir =  count <0 ? 'in' : 'out' 
    r= db.execute {  "select from ( traverse #{dir}(\"grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth = #{count.abs} " }  
    if r.size == 1
      r.first
    else
      nil
    end
  end


  def analyse_key key

    new_key=  if key.first.is_a?(Range) 
			   key.first
			elsif key.size ==1
			 key.first
			else
			  key
			end
  end

  def environment previous_items = 10, next_items = nil
    next_items =  previous_items  if next_items.nil?  # default : symmetric fetching

    my_query =  -> (count) { dir =  count <0 ? 'in' : 'out';   db.execute {  "select from ( traverse #{dir}(\"grid_of\") from #{rrid} while $depth <= #{count.abs}) where $depth >=1 " } }  # don't fetch self
    
   prev_result = previous_items.zero? ?  []  :  my_query[ -previous_items ] 
   next_result = next_items.zero? ?  []  : my_query[ next_items ] 

    prev_result.reverse  << self | next_result 
  end
end
