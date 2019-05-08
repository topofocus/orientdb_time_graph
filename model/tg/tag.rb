#ActiveOrient::Model.orientdb_class name: 'time_base', superclass: 'V'
class  TG::Tag # < TG::TimeBase
	def monat
		in_tg_day_of.out.value_string.first
	end

	def die_stunde h
		h.to_i >0 && h.to_i<31 ? out_tg_time_of[h].in : nil
	end

	def stunde *key
		if key.empty?
			out_tg_time_of.in
		else
			q = OrientSupport::OrientQuery.new
			q.nodes :out, TG::TIME_OF, condition: { value: key } 
			query q
			#    query( "select  expand (out_tg_time_of.in[#{db.generate_sql_list 'value' => key.analyse}]) from #{rrid}  ")
		end
	end


  def monat
    in_tg_day_of.out.first
  end

  def datum
    m = monat
     Date.new m.jahr.value, m.value, value #   "#{ value}.#{m.value}.#{m.jahr.value}"
  end

=begin
 Fetches the vertex corresponding to the given date

 (optional:  executes the provided block on the vertex )

 Example:

	start_date=  Date.new(2018,4,25)
	TG::Tag.fetch( start_date){ |x| x.datum }  
	=> ["25.4.2018"] 
  TG::Tag.fetch( start_date){ |x| x.data_nodes( ML::L_OHLC).map &:to_human }
  INFO->select  expand (  outE('tg_day_of').in[ value = 25 ]  ) from 
	 	  ( select  expand (  outE('tg_month_of').in[ value = 4 ]  ) from  
			( select  from tg_jahr where value = 2018  )    )   
  INFO->select  expand (  outE('ml_l_ohlc').in  ) from #82:8927  
  => ["<Ohlc[161:22]: in: {ML::L_OHLC=>1}, 
	    close : 3485.83, high : 3500.6, low : 3464.35, open : 3500.6, time : 2018-04-25 00:00:00, 
			trades : 1831, volume : 0, wap : 0.0>"] 
=end
	def self.fetch datum , &b  # parameter: a date
#		query_database( "select  expand (out_tg_day_of.in[value = #{datum.day}]) from (select  expand (out_tg_month_of.in[value = #{datum.month}]) from (select from tg_jahr where value = #{datum.year} ) ) ") &.first
		q = OrientSupport::OrientQuery.new  from: TG::Jahr, where: { value: datum.year }
		w = OrientSupport::OrientQuery.new  from: q
		w.nodes :out, via: TG::MONTH_OF, where: { value: datum.month }
		x = OrientSupport::OrientQuery.new  from: w 
		x.nodes :out, via: TG::DAY_OF, where: { value: datum.day }
		
		query_database( x,  &b).first 
	end

end
