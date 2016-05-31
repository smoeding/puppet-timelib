# addtime.rb --- Add a time interval to a time

module Puppet::Parser::Functions
  newfunction(:addtime, :type => :rvalue, :doc => <<-'EOS') do |args|

    Add a time interval to a time.

    The first argument is mandatory and must be a time in the 'hh:mm:ss',
    'hh:mm' or 'hh' format. It can also be a numeric value in which case it
    is interpreted as the number of hours. The value must be a valid time, so
    the hours value must be between 0 and 23 and the minutes and seconds
    values must be between 0 and 59.

    The second argument is also mandatory and must be a time duration in the
    'PT[n]H[n]M[n]S' format defined by ISO 8601. The 'PT' prefix indicates
    that is is a time period. The number of hours, minutes and seconds follow
    by giving a numerical value and the 'H', 'M' or 'S' suffix.

    The optional third argument is a boolean that indicates if the result
    should be an array (hours, minutes, seconds) or a formatted string in
    'hh:mm:ss' format. By default the function returns the formatted string.

    Usage:

      $midnight = addtime('23:59:59', 'PT1S')    # '00:00:00'

      $noon     = addtime('11:03:17', 'PT56M43S) # '12:00:00'

      $wakeup   = addtime('00:00', 'PT6H', true) # [ 6, 0, 0 ]
    EOS

    unless [2, 3].include?(args.size)
      raise(Puppet::ParseError, "addtime(): Wrong number of arguments " +
                                "given (#{args.size})")
    end

    hrs1, min1, sec1 = 0, 0, 0
    hrs2, min2, sec2 = 0, 0, 0

    #
    # 1. argument: time
    #
    if args[0].is_a?(Numeric)
      hrs1 = args[0].to_i
    elsif args[0].is_a?(String)
      if args[0] =~ /^(\d+)$/
        hrs1 = $1.to_i
      elsif args[0] =~ /^(\d+):(\d+)$/
        hrs1 = $1.to_i
        min1 = $2.to_i
      elsif args[0] =~ /^(\d+):(\d+):(\d+)$/
        hrs1 = $1.to_i
        min1 = $2.to_i
        sec1 = $3.to_i
      else
        raise Puppet::ParseError, "addtime(): Wrong format for first argument."
      end
    else
      raise Puppet::ParseError, "addtime(): Wrong type for first argument."
    end

    if (hrs1 > 23) or (min1 > 59) or (sec1 > 59)
      raise Puppet::ParseError, "addtime(): Time argument out of range."
    end

    # Use UTC to prevent any issues with daylight saving time
    time = Time.utc(2000, 1, 1, hrs1, min1, sec1)

    #
    # 2. argument: duration
    #

    unless args[1].is_a?(String)
      raise Puppet::ParseError, "addtime(): Wrong type for second argument."
    end

    unless args[1] =~ /^PT\d/i
      raise Puppet::ParseError, "addtime(): Wrong format for second argument."
    end

    unless args[1] =~ /^PT([0-9]+H)?([0-9]+M)?([0-9]+S)?$/i
      raise Puppet::ParseError, "addtime(): Wrong format for second argument."
    end

    hrs2 = $1.to_i if args[1] =~ /(\d+)H/i
    min2 = $1.to_i if args[1] =~ /(\d+)M/i
    sec2 = $1.to_i if args[1] =~ /(\d+)S/i

    # Add duration
    time += (3600 * hrs2) + (60 * min2) + sec2

    if args[2]
      [time.hour, time.min, time.sec]
    else
      time.strftime "%T"
    end
  end
end
