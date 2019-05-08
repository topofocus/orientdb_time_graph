## We are defining to_tg methods for Strings, Date and DateTiem objects.
## Strings are converted to the time format.
#
class Date
  def to_tg
# old method performed queries
# Date.today.to_tg
# INFO->select from tg_jahr where value = 2019
# INFO->select  expand (out_tg_month_of.in[value = 4]) from #117:0  
# INFO->select  expand (out_tg_day_of.in[value = 2]) from #108:6  
# 
# the alternative:
#    TG::Jahr[year].monat(month).tag(day).orient_flatten
# which can be combined through
#		query "select  expand (out_tg_day_of.in[value = #{day}]) from (select  expand (out_tg_month_of.in[value = #{month}]) from (select from tg_jahr where value = #{year} ) ) "
#
# this is realized in fetch
		TG::Tag.fetch self
  end
end

class DateTime
  def to_tg
    if TG::TIME_OF.count >0 
      TG::Monat[month].tag(day).stunde(hour).pop.pop
    else
		TG::Tag.fetch self
    end
  end
end

class String
  def to_tg
    date =  DateTime.parse(self)
    date.to_tg
  end
end

