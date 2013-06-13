require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'pry'

def fetch_doc(url)
  response = open(url)
  Nokogiri::HTML(response)
end

def scrape_student_info(doc)
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
  return student
end

def scrape_content_info(doc, student_id)
  content = []
  boxes = doc.search("div.services")
  boxes.each_with_index do |box, index|
    content_box = {}
    content_box[:student_id] = student_id
    content_box[:section_id] = index + 1
    content_box[:title] = box.search("h3").text
    content_box[:body_text] = box.text.strip.split("\n")[1..-1].join("\n").strip.gsub(/ {1,}/,' ')
    content << content_box
  end
  return content
end

def create_student_table(student, db)
  remaining_columns = student.keys.collect { |key| "#{key} TEXT" }
  db.execute("CREATE TABLE student (
      id INTEGER PRIMARY KEY AUTOINCREMENT, #{remaining_columns.join(',')}
    );")
end

def create_content_table(db)
  db.execute("
    CREATE TABLE content (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id int,
      section_id int,
      title TEXT,
      body_text TEXT
    );")
end

def insert_student(student, db)
  student_column_values = student.collect { |key, values| values }
  db.execute("INSERT INTO student(#{student.keys.join(',')})
                VALUES (?,?,?,?,?,?,?,?,?,?)", student_column_values)
end

def insert_content(content, db)

  content_column_values = content.collect do |content_row|
    [content_row[:student_id], content_row[:section_id], content_row[:title], content_row[:body_text]]
  end
  db.execute("INSERT INTO content(student_id, section_id, title, body_text)
                VALUES #{("(?,?,?,?),"*9)[0..-2]}", content_column_values.flatten)
end

def scrape_links(links,db)
  links.each_with_index do |link, index|
    doc = fetch_doc(link) #=> returns nokogiri doc
    student = scrape_student_info(doc) #=> student hash
    content = scrape_content_info(doc, index) #=> array of content hashes
    if index.zero? # so we only create tables once
      create_student_table(student, db)
      create_content_table(db)
    end
    insert_student(student, db)
    insert_content(content, db)
  end
end


# kicks off program
File.delete("students.db") if File.exists?("students.db")
db = SQLite3::Database.new( "students.db" )
index_doc = fetch_doc("http://students.flatironschool.com/")
links = index_doc.search(".blog-title a")
          .collect{|link| "http://students.flatironschool.com/#{link.attr("href")}".downcase}
          .delete_if{|url| url == "http://students.flatironschool.com/#"}
          .delete_if{|url| url =~ /waxman/} # bad link
scrape_links(links,db)
binding.pry