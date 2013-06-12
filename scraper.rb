require 'nokogiri'
require 'open-uri'
require 'sqlite3'

# response = open("http://students.flatironschool.com/students/thomas.html")
response = File.open("kristencurtis.html")
doc = Nokogiri::HTML(response)


#################### our student info ##########################################

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


################### our content info ###########################################

content = []
boxes = doc.search("div.services")

boxes.each do |box|
  content_box = {}
  content_box[:title] = box.search("h3").text
  content_box[:text] = box.search("p,li").text.strip.gsub(/ {1,}/,' ')
  content << content_box
end

puts student.inspect
puts content.inspect

remaining_columns = student.keys.collect do |key|
  "#{key} TEXT"
end

create_student_table_statement = "CREATE TABLE student (
    id INTEGER PRIMARY KEY AUTOINCREMENT, #{remaining_columns.join(',')}
  );"

# puts create_student_table_statement

db = SQLite3::Database.new( "students.db" )
db.execute(create_student_table_statement)

create_content_table_statement = "CREATE TABLE content (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id int,
  section_id int,
  title TEXT,
  text TEXT
  );"

puts create_content_table_statement

db.execute(create_content_table_statement)


# sections = doc.search(".services-wrap").to_a
# sections.delete_at(1) # get rid of coder cred
# sections.each do |section|
# end
# social_links.each do |link|
#   short_url = link.match(/https?:\/\/(www.)?([^\/]+)/)[2]
# end
# 
# 