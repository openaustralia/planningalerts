# Override default order of long and long_ordinal and also don't include a comma before the year
Date::DATE_FORMATS[:long] = "%e %B %Y"
Date::DATE_FORMATS[:long_ordinal] = lambda { |date|
  day_format = ActiveSupport::Inflector.ordinalize(date.day)
  date.strftime("#{day_format} %B %Y")
}

# Override default order of long, don't include a comma before the year and don't use zero
# padding for the day of the month
Time::DATE_FORMATS[:long] = "%d %B %Y %H:%M"
