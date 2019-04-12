## We are defining to_tg methods for Strings, Date and DateTiem objects.
## Strings are converted to the time format.
#
class Date
  def to_tg
		# performs 3 queries
		# Date.today.to_tg
		# INFO->select from tg_jahr where value = 2019
		# INFO->select  expand (out_tg_month_of.in[value = 4]) from #117:0  
		# INFO->select  expand (out_tg_day_of.in[value = 2]) from #108:6  
# 
    TG::Jahr[year].monat(month).tag(day).pop.pop
#		which can be combined through
#		"select  expand (out_tg_day_of.in[value = 2]) from (select  expand (out_tg_month_of.in[value = 4]) from (select from tg_jahr where value = 2019) )
#		q =  OrientSupport::OrientQuery.new 
  end
end

class DateTime
  def to_tg
    if TG::TIME_OF.count >0 
      Monat[month].tag(day).stunde(hour).pop.pop
    else
      TG::Jahr[year].monat(month).tag(day).pop.pop
    end
  end
end

class String
  def to_tg
    date =  DateTime.parse(self)
    date.to_tg
  end
end

