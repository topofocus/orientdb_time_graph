class TG::Monat # < TG::TimeBase
	# starts at a given month-entry
	#   tg_monat.in tg_month_of out --> tg_jahr
	def _jahr
		query.nodes :in, via: TG::MONTH_OF
	end
  def der_tag d
#    d=d-1
    d >0 && d<31 ? out_tg_day_of[d].in : nil
  end
 
  # returns an array of days
  # thus enables the use as  
  #   Monat[9].tag[9]
  def tag *key
    if key.blank? 
			out_tg_day_of.in
    else
#			out_tg_day_of.in
			key=  key.first		if key.size == 1
			nodes( :out, via: /day/ , where: { value: key } )
    end
  end

  # returns the specified edge 
  #  i.e.  Monat[9]
  #

  def jahr
		_jahr.execute.first
#    in_tg_month_of.out.first
  end

	# returns the absolute Month-Value
  #
  # enables easy calculations betwwen month-vertices
	#
	# i.e.  TG::Jahr[2013].monat(4).abs_value.first - TG::Jahr[2012].monat(9).abs_value.first 
	#       => 7
	def abs_value
		jahr.value * 12 + value
	end

	def self.fetch datum , &b  # parameter: a date
#		query_database( "select  expand (out_tg_day_of.in[value = #{datum.day}]) from (select  expand (out_tg_month_of.in[value = #{datum.month}]) from (select from tg_jahr where value = #{datum.year} ) ) ") &.first
		q = OrientSupport::OrientQuery.new  from: TG::Jahr, where: { value: datum.year }
		w = OrientSupport::OrientQuery.new  from: q
		w.nodes :out, via: TG::MONTH_OF, where: { value: datum.month }
		
		query_database( w,  &b).first 
	end

#TG::Monat.fetch Date.new(2000,4,5)
#21.06.(06:29:11) INFO->select  expand (  outE('tg_month_of').in[ value = 4 ]  ) from  ( select from tg_jahr where value = 2000  )  
# => #<TG::Monat:0x00000000032fbe28 @metadata={:type=>"d", :class=>"tg_monat", :version=>34, :fieldTypes=>"out_tg_day_of=g,in_tg_month_of=g,in_tg_grid_of=g,out_tg_grid_of=g", :cluster=>132, :record=>225, :edges=>{:in=>["tg_month_of", "tg_grid_of"], :out=>["tg_day_of", "tg_grid_of"]}}, @d=nil, @attributes={:out_tg_day_of=>["#158:6859", "#159:6859", "#160:6859", "#153:6860", "#154:6860", "#155:6860", "#156:6860", "#157:6860", "#158:6860", "#159:6860", "#160:6860", "#153:6861", "#154:6861", "#155:6861", "#156:6861", "#157:6861", "#158:6861", "#159:6861", "#160:6861", "#153:6862", "#154:6862", "#155:6862", "#156:6862", "#157:6862", "#158:6862", "#159:6862", "#160:6862", "#153:6863", "#154:6863", "#155:6863"], :in_tg_month_of=>["#164:225"], :value=>4, :in_tg_grid_of=>["#173:7103"], :out_tg_grid_of=>["#172:7107"]}> 

end
