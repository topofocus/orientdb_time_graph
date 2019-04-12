class TG::Stunde # < TG::TimeBase

  def tag
    in_tg_time_of.out
  end

  def datum
    month = in_tg_time_of.out.in_tg_day_of.out.value
    day =  in_tg_time_of.out.value
    "#{day.first}.#{month.flatten.first}.#{Date.today.year} #{value}:00"
  end
  def next
    puts value.inspect
    in_tg_day_of.out.first.tag( value + 1 )
  end
end
