# frozen_string_literal: true

namespace :migrate do
  task process_submissions: :environment do
    courses_scope = Course.all.select { _1.title.downcase.include? "python" }
    courses_scope.each do |course|
      puts "Processing course #{course.title} (#{course.id})"

      course.submissions.each do |submission|
        result = Submission::ProcessJob.perform_now(result)

        puts result
      rescue => e
        puts e.inspect
      end
    end
  end
end
