# dump the reuters dataset from http://kdd.ics.uci.edu/databases/reuters21578/reuters21578.html
# into a single file, one line per article

require 'hpricot'

# config 
directory = '.'

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

output = File.new('reuters.bulk.json', 'w')

Dir.entries(directory).select{ |i| i=~ /sgm$/}.each do |filename|
  file = File.new("#{ directory }/#{ filename }", 'r').read
  xml = Hpricot(file)
  articles = xml.search('/REUTERS')

  puts "Reading #{filename} : #{ articles.length} articles"

  articles.each{ |article|
    begin 
      body = (article/"*/BODY").innerHTML
      title = (article/"*/TITLE").innerHTML

      clean_body = clean_string(body)
      clean_title = clean_string(title)
    
      output.puts("{ \"index\": {}}")
      output.puts("{ \"title\": \"#{clean_title}\", \"body\": \"#{clean_body}\" }")
    rescue Exception => e  
      puts "Error parsing article: #{e.message}"      
      puts e.backtrace.inspect
    end 
  }
end

output.close
