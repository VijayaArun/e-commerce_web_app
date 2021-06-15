# require 'find'
# images = []
# Find.find("/home/pooja/Documents/shree sarees" &&"*.jpg" || "*.png") do |path|
# 	images << path if path = ~ /.*\.jpg$/
# # Dir["*.jpg","*.png"]
# # Dir.foreach("/documents/shree sarees/*") do |image|
# 	# next if image == 
# 	# require file
# end

# image_file_paths = Find.find('/home/pooja/Documents/shree sarees/cotton/201 bp').select { |p| /.*\.jpg$/ || /.*\.png$/ =~ p }
# for identifier in image_file_paths
# 	if image_file_paths.identifier[-7,3].to_i.kind_of?Integer 

# 	end
# end


# folder = '/home/pooja/Documents/shree sarees'
# Dir.glob("#{folder}/**/*.jpg")


# Dir.foreach("/home/pooja/Documents/shree sarees/cotton/201 bp") do |file|
#      if file.split(/\W+/).last == "jpg" || file.split(/\W+/).last == "png"
#        if file[-7,3].to_i.kind_of?Integer
#        	puts file[-7,3]
#        else
#          puts "error"
#        end
#     end
# end

# Dir.chdir("/home/pooja/Documents/shree sarees")
# Dir.glob(File.join("**","*.jpg")) || Dir.glob(File.join("**","*.png"))


# Dir.chdir("/home/pooja/Documents/shree sarees") { Dir.glob("**/*").map {|path| File.expand_path(path) } }

# for files in  Dir['**/*.*']
# if files[-7,3].to_i.kind_of?Integer
#        	puts files[-7,3]
#        else
#          puts "error"
#        end
#    end

#      Dir['**/*.*'].each do |file|
#     	if file.split(/\W+/).last == "jpg" || file.split(/\W+/).last == "png"
#        if file[-7,3].to_i.kind_of?Integer
#        	puts file[-7,3]
#        else
#          puts "error"
#        end
#     end
# end


# require 'find'
# Find.find('./') do |f| p f end

# #Jpg and png files
# Find.find('./') do |file|
# file = Dir.glob(File.join("**","*.jpg")) << Dir.glob(File.join("**","*.png"))
#    p file.split(/\s+|\b/)
# end



	
# # Displays Folder names
#   condition = Dir["*.jpg","*.png"]
#   Dir.glob(File.join("**", condition))



#  condition = Dir["*.jpg","*.png"]
#   f = Dir.glob(File.join("**", condition))
#   Dir.glob(File.join(f, condition))

#   Find.find('./') do |file|
#   	file_type = []
#   	file_type = File.extname(file)
#   	if file_type == ".jpg" || file_type == ".png"
#   		puts File.basename(file,file_type)
#   	else
#   		puts "not jpg or png"
#   	end
#   end

#   files = File.join("**", "*.jpg" , "**" , "*.png")
#   Dir.glob(files)




# Find.find('./') do |file|
# file_type = []
# file_type = File.extname(file)
# if file_type == ".jpg" || file_type == ".png"
# fname = File.basename(file,file_type).split(/\W+/)
# if fname[-3,3].to_i.kind_of?Integer
# puts fname[-3,3]
# else
# puts "alphabets"
# end
# end
# end









#Gives last 3 chars of all jpg and png files for product name.
def get_product_name
	Dir['**/*.{jpg,png}'].each do |file|
		fname = File.basename(file.to_s , '.*').split(/\W+/)
		fname = fname.pop
		fname.split(",").map {|x| x.to_i }
		puts fname.last(3)
	end
end


#Gives all folder names 
def get_taxanomies
	unique_folder_names =[]
	Dir.glob("**/").each do |folder|
		folder_name = folder.split('/').second
		if folder_name != nil
			folder_name = folder_name.gsub(/[^0-9A-Za-z]/, '').gsub(/[^\d]/, '')
		  unique_folder_names << folder_name
		end
	end
	p unique_folder_names.uniq
end

#Gives all categories
def get_categories
	Dir.glob("**").each do |folder|
		p folder
	end
end

# #Reading prices from excel sheet
# require 'spreadsheet'
# workbook = Spreadsheet.open '/home/pooja/Documents/ADI PRICE LIST 01-05-16.xls'
# workbook.worksheets.each do |sheet|
#   sheet.each do |row|
#     puts "#{sheet.name} --> #{row[0]} - #{row[1]} - #{row[2]}"
#   end
# end

#Reading prices from csv file
# require "CSV"
# CSV.foreach("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv") do |row|
# 	puts "#{row}"
# end



# require "CSV"
 
# filename = 'data.csv'
# sum = 0
# CSV.foreach("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv") do |row|
#   sum += row[2].to_i
# end
 
# puts sum


# arr_of_arrs = CSV.read("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv")


# require 'csv'
# data = Array.new
# CSV.foreach("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv") do |row|
# data << row.to_hash
# end
#  p data


# CSV.open("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv", skip_blanks: true).reject { |row| row.all?(&:nil?) }
# CSV.readlines("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv", skip_blanks: true).reject { |row| row.all?(&:nil?) } 
# CSV.open("/home/pooja/Documents/ADI PRICE LIST 01-05-16.csv", skip_blanks: true, headers: true).reject { |row| row.to_hash.values.all?(&:nil?) }





# ‘*’ – matches all files and directories in the current path
# ‘**’ – matches all files and directories in the current path
# ‘**/’ – matches all directories recursively in the current path
# ‘**/*’ – matches all files and directories recursively in the current path