namespace :sufia do
  namespace :user do

    desc "list user's email"
    task "list_emails", [:file_name] => :environment do |cmd, args|
      file_name = args[:file_name]
      file_name ||= "user_emails.txt"
      users = User.all.map {|user| user.email}.reject {|email| email.blank?}
      f = File.new(file_name,  "w")
      f.write(users.join(", "))
      f.close
    end
  end
end