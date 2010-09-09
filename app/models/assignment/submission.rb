class Assignment::Submission < ActiveRecord::Base
  belongs_to :status, :class_name  => "Assignment::SubmissionStatus", 
                      :foreign_key => "submission_status_id"
end
