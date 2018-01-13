class StaffMember
  include ActiveModel::Model
  def events; {} end
  def timezone; Time.find_zone("PST8PDT") end
  def start_hour; self.try(:start_work_hour__c) || '10:00' end
  def end_hour; self.try(:end_work_hour__c)   || '19:00' end
  def start_hour_offset; ChronicDuration.parse([start_hour, ':00'].join) end
  def end_hour_offset; ChronicDuration.parse([end_hour, ':00'].join) end

end