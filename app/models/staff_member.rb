class StaffMember
  include ActiveModel::Model
  attr_accessor :schedule, :timezone

  DEFAULT_SCHEDULE = {
    sun: ['10:00', '19:00'],
    mon: ['10:00', '19:00'],
    tue: ['10:00', '19:00'],
    wed: ['10:00', '19:00'],
    thu: ['10:00', '19:00'],
    fri: ['10:00', '19:00'],
    sat: ['10:00', '19:00']
  }

  def initialize(schedule: DEFAULT_SCHEDULE, timezone: Time.find_zone("PST8PDT"))
    @schedule = convert_to_duration(DEFAULT_SCHEDULE.merge(schedule))
    @timezone = timezone
  end

  def convert_to_duration(schedule)
    new_schedule = {}
    schedule.each do |weekday, (start_hour, end_hour)|
      new_schedule[weekday] = [
        ChronicDuration.parse([start_hour, ':00'].join),
        ChronicDuration.parse([end_hour, ':00'].join)
      ]
    end

    new_schedule
  end
end
