## We are defining to_tg methods for Strings, Date and DateTiem objects.
## Strings are converted to the time format.
#
class Date
  def to_tg
    TG::Jahr[year].monat(month).tag(day).pop.pop
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

