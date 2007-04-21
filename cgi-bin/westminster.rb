#!/opt/local/bin/ruby

description = nil
address = nil
ref = nil
getaddress = false
url = nil

puts '<planning>
<authority_name>City of Westminster</authority_name>
<authority_short_name>Westminster</authority_short_name>
<applications>'

while line = gets
  if line.index('Proposal:')
    description = line.gsub('<tr><td class="tablefeature">Proposal:</td><td class="tablefeature">','').gsub('</td></tr>','').strip
  end

  if line.index('<tr><td><a href="currentsearch-details.cfm?CASENO=')
    ref = line.gsub('<tr><td><a href="currentsearch-details.cfm?CASENO=','').gsub('</a></td></tr>','').strip
    ref = ref[ref.index('>')+1..ref.length]

    url = line.gsub('<tr><td><a href="','')
    url = url[0, url.index('">')]
  end

  if getaddress
    getaddress = false if line.index('Proposal:')
  end

  if getaddress
    address += line.gsub('</td></tr>','').strip + ' '
  end

  if line.index('<tr><td class="tablefeature">Address:</td><td class="tablefeature">')
    address = line.gsub('<tr><td class="tablefeature">Address:</td><td class="tablefeature">','').strip + ' '
    getaddress = true
  end

  if line.index('</table>') and address
      puts '<application>'
      puts "<council_reference>#{ref}</council_reference>"
      puts "<address>#{address.strip}</address>"
      if address
        m = address.strip.match(/[A-Z]?[A-Z]\d?\d \d[A-Z][A-Z]/)
        if m
          puts "<postcode>#{m}</postcode>"
        else
          puts "<postcode></postcode>"
        end
      end
      puts "<description>#{description}</description>"

      puts "<info_url>http://www3.westminster.gov.uk/planningapplications/#{url}</info_url>"
      puts "<comment_url></comment_url>"

      puts '</application>'

  end
  
end

puts '</applications>'
puts '</planning>'
