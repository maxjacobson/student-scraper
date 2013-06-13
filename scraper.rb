require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'pry'

# response = open("http://students.flatironschool.com/students/sarahduve.html")
response = File.open("kristencurtis.html")
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
  content_box[:body_text] = box.search("p,li").text.strip.gsub(/ {1,}/,' ')
  content << content_box
end


####################### STUDENT TABLE #######################################

remaining_columns = student.keys.collect do |key|
  "#{key} TEXT"
end

create_student_table_statement = "
    CREATE TABLE student (
    id INTEGER PRIMARY KEY AUTOINCREMENT, #{remaining_columns.join(',')}
  );"

db = SQLite3::Database.new( "students.db" )
db.execute(create_student_table_statement)

student_column_values = student.collect do |key, values|
  # "'#{values}'"
  values
end

# binding.pry

# insert_student_table_statement = "
#   INSERT INTO student(#{student.keys.join(',')} ) 
#   VALUES (#{student_column_values.join(',')}
#     );"

# commenting for posterity
# db.execute(insert_student_table_statement)

# Execute inserts with parameter markers
# db.execute("INSERT INTO students (name, email, grade, blog) 
#             VALUES (?, ?, ?, ?)", [@name, @email, @grade, @blog])

db.execute("INSERT INTO student(#{student.keys.join(',')})
              VALUES (?,?,?,?,?,?,?,?,?,?)", student_column_values)

# binding.pry


######################## CONTENT TABLE #####################################

create_content_table_statement = "
  CREATE TABLE content (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id int,
    section_id int,
    title TEXT,
    body_text TEXT
  );"

db.execute(create_content_table_statement)

content_column_values = content.collect do |content_row|
  # "(1, #{content_row[:section_id]}, \"#{content_row[:title]}\", \"#{content_row[:body_text]}\")"
  [1, content_row[:section_id], content_row[:title], content_row[:body_text]]
end


# binding.pry
# 

db.execute("INSERT INTO content(student_id, section_id, title, body_text)
              VALUES #{("(?,?,?,?),"*9)[0..-2]}", content_column_values.flatten)

binding.pry

# insert_content_table_statement = "
#   INSERT INTO content (student_id, section_id, title, body_text) 
#   VALUES
#     #{content_column_values.join(',')}
#   ;"

# db.execute(insert_content_table_statement)

