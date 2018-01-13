# class StaffMemberSchedule < Struct.new(:staff_member, :since, :till, :duration, :timezone)
class StaffMemberSchedule < Dry::Struct


  module BitMask
    QuantSize = 5.minutes

    # Preconditions:
    # end_of_base_time <= interval
    def interval_to_bitmask interval:, end_of_base_time:
      interval.try {|a,b|
        ((1 << ((b-a) / QuantSize).to_i) - 1) <<
            ((end_of_base_time - b) / QuantSize).to_i }
    end

    def round_down_to_five_minutes time
      Time.zone.at(time.to_i / QuantSize * QuantSize).in_time_zone(time.time_zone)
    end

    def round_up_to_five_minutes time
      Time.zone.at(time.to_i / QuantSize * QuantSize).in_time_zone(time.time_zone)
    end
  end

  extend BitMask
  include BitMask

  # .new(:staff_member, :since, :till, :duration, :timezone)
  attribute :staff_member, Types::Any
  attribute :since, Types::Strict::Time
  attribute :till, Types::Strict::Time
  attribute :duration, Types.Instance(ActiveSupport::Duration)


  delegate :start_hour_offset, :end_hour_offset, :timezone, :events, to: :staff_member


  def initialize *args
    super *args
    @since = since.beginning_of_day
    self.timezone ||= since.time_zone
    @till  = self.class.round_up_to_five_minutes   till.to_time.in_time_zone(timezone)
  end



  def openings
    return free_slots_chunk.map(&:first)
  end


  def free_slots_chunk
    conflicting = {}

    quants_in_appointment_duration = (duration / QuantSize).ceil.to_i

    (conflicting.map {|a,b| [ [a,since].max, [b, till].min ]} + off_work_intervals).
        reject {|a,b| a == b}.
        # ^ unquanted intervals
        map    {|a,b| interval_to_bitmask interval: [a,b], end_of_base_time: till}.
        # ^ quantize intervals
        reduce(&:|).  # UNIONS (bit-or) ALL INTERVALS
    # ^ find union and free slots
    to_s(2).      # convert to binary string representation like '0010010111001'
    chars.map.with_index.chunk{ |bit, idx| bit == '0' }.
        select do |is_vacant_interval, indexed_quants|
      is_vacant_interval && indexed_quants.size >= quants_in_appointment_duration
    end.
        flat_map do |_, continuous_window_of_vacant_quant_indeces|
      continuous_window_of_vacant_quant_indeces.map(&:second).each_slice(quants_in_appointment_duration).
          select{ |e| e.size == quants_in_appointment_duration }.map(&:minmax)
    end.
        map {|a, b| [since +  a * QuantSize, since + (b + 1) * QuantSize] }
  end


  #todo: change +1 second to beginning_of_next_day
  def off_work_intervals
    [since, till].
        map {|e| e.in_time_zone(staff_member.timezone).to_date }.
        try{|e| Range.new(*e).step(1) }.
        map {|e| e.in_time_zone(staff_member.timezone) }.
        flat_map do |staff_member_tz_day|

        a = [staff_member_tz_day.beginning_of_day, staff_member_tz_day + start_hour_offset]
        b = [staff_member_tz_day + end_hour_offset, staff_member_tz_day.tomorrow.beginning_of_day]
        [a, b]

    end.
        reject {|x,y| y < since || x > till }.     # reject non-overlapping intervals
    map {|x,y| [if x < since then since else x end, if y > till then till else y end]} # cut corners
  end


  # private

  def staff_member_timezone_interval_wrapping_given_interval
    [staff_member.timezone.at(since).beginning_of_day, staff_member.timezone.at(till).tomorrow.beginning_of_day]
  end


end
