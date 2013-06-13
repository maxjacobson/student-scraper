require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'pry'


db = SQLite3::Database.new( "students.db" )
index_response = open("http://students.flatironschool.com/")
index_doc = Nokogiri::HTML(index_response)
links = index_doc.search(".blog-title a").collect{|link| "http://students.flatironschool.com/#{link.attr("href")}".downcase}.delete_if{|url| url == "http://students.flatironschool.com/#"}








links.each do |link|

end



# response = open("http://students.flatironschool.com/students/sarahduve.html")
response = File.open("sarahduve.html")
doc = Nokogiri::HTML(response)

#################### STUDENT SCRAPE ##########################################

student = {}

student[:name] = doc.search(".ib_main_header").text
student[:image_url] = doc.search("img.student_pic").attr("src").value
student[:quote] = doc.search(".quote-div h3").text

social_links = doc.search(".social-icons a").collect { |link| link.attr("href") }
student[:twitter_url]  = social_links[0]
student[:linkedin_url] = social_links[1]
student[:github_url]   = social_links[2]
student[:blog_url]     = social_links[3]

coder_cred_links = doc.search(".coder-cred a").collect { |link| link.attr("href") }
student[:treehouse_url]  = coder_cred_links[1]
student[:codeschool_url] = coder_cred_links[2]
student[:coderwall_url]  = coder_cred_links[3]


################### CONTENT SCRAPE ###########################################

content = []
boxes = doc.search("div.services")

boxes.each_with_index do |box, index|
  content_box = {}
  content_box[:section_id] = index + 1
  content_box[:title] = box.search("h3").text
  content_box[:body_text] = box.text.strip.split("\n")[1..-1].join("\n").strip.gsub(/ {1,}/,' ')
  content << content_box
end

####################### STUDENT TABLE #######################################

remaining_columns = student.keys.collect do |key|
  "#{key} TEXT"
end


db.execute("
    CREATE TABLE student (
    id INTEGER PRIMARY KEY AUTOINCREMENT, #{remaining_columns.join(',')}
  );")

student_column_values = student.collect { |key, values| values }

db.execute("INSERT INTO student(#{student.keys.join(',')})
              VALUES (?,?,?,?,?,?,?,?,?,?)", student_column_values)


######################## CONTENT TABLE #####################################

db.execute("
  CREATE TABLE content (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id int,
    section_id int,
    title TEXT,
    body_text TEXT
  );")

content_column_values = content.collect do |content_row|
  [1, content_row[:section_id], content_row[:title], content_row[:body_text]]
end


db.execute("INSERT INTO content(student_id, section_id, title, body_text)
              VALUES #{("(?,?,?,?),"*9)[0..-2]}", content_column_values.flatten)