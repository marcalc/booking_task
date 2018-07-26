require 'test_helper'

class StaffMemberScheduleTest < ActiveSupport::TestCase
  utc = Time.find_zone("UTC")
  test "default opening hours" do
    schedule = StaffMemberSchedule.new(
      since: Time.new(2018, 7, 23),
      till: Time.new(2018, 7, 24),
      staff_member: StaffMember.new,
      duration: 45.minutes,
    )

    assert_equal 12, schedule.openings.count
  end

  test "default opening hours with timezone" do
    schedule = StaffMemberSchedule.new(
      since: Time.utc(2018, 7, 23),
      till: Time.utc(2018, 7, 24),
      staff_member: StaffMember.new(timezone: utc),
      duration: 45.minutes,
    )

    assert_equal 12, schedule.openings.count
  end

  test "custom opening hours" do
    schedule = StaffMemberSchedule.new(
      since: Time.utc(2018, 7, 23),
      till: Time.utc(2018, 7, 24),
      staff_member: StaffMember.new(
        timezone: utc,
        schedule: {
          mon: ['01:00', '03:00']
        }
      ),
      duration: 45.minutes
    )

    openings = schedule.openings

    assert_includes openings, Time.utc(2018, 07, 23, 01, 00, 00)
    assert_includes openings, Time.utc(2018, 07, 23, 01, 45, 00)

    assert_equal 2, openings.count
  end

  test "custom opening hours on weekends" do
    schedule = StaffMemberSchedule.new(
      since: Time.utc(2018, 7, 27),
      till: Time.utc(2018, 7, 30),
      staff_member: StaffMember.new(
        timezone: utc,
        schedule: {
          sun: ['14:00', '16:15'],
          sat: ['14:00', '16:15']
        }),
      duration: 45.minutes
    )

    openings = schedule.openings

    assert_includes openings, Time.utc(2018, 7, 27, 10, 00)
    assert_includes openings, Time.utc(2018, 7, 27, 10, 45)
    assert_includes openings, Time.utc(2018, 7, 27, 11, 30)
    assert_includes openings, Time.utc(2018, 7, 27, 12, 15)
    assert_includes openings, Time.utc(2018, 7, 27, 13, 00)
    assert_includes openings, Time.utc(2018, 7, 27, 13, 45)
    assert_includes openings, Time.utc(2018, 7, 27, 14, 30)
    assert_includes openings, Time.utc(2018, 7, 27, 15, 15)
    assert_includes openings, Time.utc(2018, 7, 27, 16, 00)
    assert_includes openings, Time.utc(2018, 7, 27, 16, 45)
    assert_includes openings, Time.utc(2018, 7, 27, 17, 30)
    assert_includes openings, Time.utc(2018, 7, 27, 18, 15)
    assert_includes openings, Time.utc(2018, 7, 28, 14, 00) # saturday
    assert_includes openings, Time.utc(2018, 7, 28, 14, 45) # saturday
    assert_includes openings, Time.utc(2018, 7, 28, 15, 30) # saturday
    assert_includes openings, Time.utc(2018, 7, 29, 14, 00) # sunday
    assert_includes openings, Time.utc(2018, 7, 29, 14, 45) # sunday
    assert_includes openings, Time.utc(2018, 7, 29, 15, 30) # sunday

    assert_equal 18, openings.count
  end
end
