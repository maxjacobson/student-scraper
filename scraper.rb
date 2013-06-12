require 'nokogiri'
require 'open-uri'
# require 'sqlite3'

# response = open("http://students.flatironschool.com/students/thomas.html")

response = File.open("kristencurtis.html")
doc = Nokogiri::HTML(response)
student = {}

#################### our searches ##############################################
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

sections = doc.search(".services-wrap").to_a
sections.delete_at(1) # get rid of coder cred

sections.each do |section|

end

# social_links.each do |link|
#   short_url = link.match(/https?:\/\/(www.)?([^\/]+)/)[2]
# end