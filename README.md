# README

schedule = StaffMemberSchedule.new(since: 1.day.from_now, till: 2.days.from_now, staff_member: StaffMember.new, duration: 45.minutes);
schedule.openings

Running the code above in the console will return chunks of 45 min intervals from to date
starting from 10 till 19

1. Extend the code to support configurable different opening hours for per staff member @done
2. Allow support for different hours in the weekend @done

**Candidate Notes:**

Run the tests using the command: `rails test`

Basically, the default options of 10 to 19 hours and PST8PDT timezone were kept, while providing a way to customize work hours for each day of the week and to provide a another time zone.

An example to customize weekend available hours below:

```
schedule = StaffMemberSchedule.new(
  since: Time.new(2018, 7, 27),
  till: Time.new(2018, 7, 30),
  staff_member: StaffMember.new(
    schedule: {
      sun: ['14:00', '16:15'],
      sat: ['14:00', '16:15']
    }),
  duration: 45.minutes
)
schedule.openings
```

**Any weekday can be customized `sun mon tue wed thu fri sat`.**

To customize the timezone, simply add the timezone argument to StaffMember.new as below:

```
utc = Time.find_zone("UTC")

schedule = StaffMemberSchedule.new(
  since: Time.new(2018, 7, 27),
  till: Time.new(2018, 7, 30),
  staff_member: StaffMember.new(
  	 timezone: utc,
    schedule: {
      sun: ['14:00', '16:15'],
      sat: ['14:00', '16:15']
    }),
  duration: 45.minutes
)
schedule.openings
```

*Also, some unused variables and methods were deleted to not create interference with this candidate's understanding.*

For mor details, please refer to `test/models/staff_member_schedule_test.rb`.
