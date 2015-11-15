# dump the reuters dataset from http://kdd.ics.uci.edu/databases/reuters21578/reuters21578.html
# into a single file, one line per article

require 'hpricot'

# config 
directory = '.'
target_dir = 'reuters.dir'

def clean_string(input, do_downcase = true, strip_reuter = true, strip_all_reuter = false, strip_trailing_comma = true, strip_trailing_period = true)
  input.encode!("UTF-8", "binary", :invalid => :replace, :undef => :replace, :replace => "?")
  input = input.split(/\s/).map{ |i| i.chomp }.select{ |i| nil == (i =~ /^&/) }

  input.map!{ |i| i.downcase } if do_downcase
  input = input[0..-2] if strip_reuter and input.last =~ /reuter/i
  input.select!{ |i| nil == (i =~ /reuter/ ) } if strip_all_reuter

  input.map!{ |i| i.sub( /,$/, '') } if strip_trailing_comma
  input.map!{ |i| i.sub( /\.$/, '') } if strip_trailing_period
  input = input.select{ |i| i != '' }.join(' ')
   
  input.gsub!(/["]/,'')  

  return input

end

Dir.mkdir target_dir unless File.exists?(target_dir)

Dir.entries(directory).select{ |i| i=~ /sgm$/}.each do |filename|
  file = File.new("#{ directory }/#{ filename }", 'r').read
  xml = Hpricot(file)
  
  sub_dir = "#{target_dir}/#{filename}"
  Dir.mkdir sub_dir unless File.exists?(sub_dir)

  articles = xml.search('/REUTERS')

  puts "Reading #{filename} : #{ articles.length} articles"

  articles.each{ |article|
    begin 
     
      id = (article)['newid']
      body = (article/"*/BODY").innerHTML
      title = (article/"*/TITLE").innerHTML

      clean_body = clean_string(body)
      clean_title = clean_string(title)
      
      output = File.new("#{sub_dir}/#{id}.txt", 'w')
      output.puts(clean_body)
      output.close

    rescue Exception => e  
      puts "Error parsing article: #{e.message}"      
      puts e.backtrace.inspect
    end 
  }
end


