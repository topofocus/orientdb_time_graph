
class TG::Jahr #< TG::TimeBase
  def der_monat m
    m >0 && m<13 ? out_tg_month_of[m].in : nil
  end
 
  # returns an array of days
  # thus enables the use as  
  #   Monat[9].tag[9]
  def monat  *key
		if key.blank?
			out_tg_month_of.in
		else
			key=  key.first		if key.is_a?(Array) && key.size == 1 
			#	out_tg_month_of[key].in
			nodes( :out, via: /month/ , where: { value: key } )
		end
  end

    
  end

