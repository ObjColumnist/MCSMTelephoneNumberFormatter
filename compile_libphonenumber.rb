# fileutils required for FileUtils.rm_rf
require 'fileutils'

@build_directory_path = File.join(Dir.pwd,'libphonenumber_build')
@libphonenumber_path = File.join(Dir.pwd,'libphonenumber.js')

# Remove Build Directory
FileUtils.rm_rf(@build_directory_path) if File.exists?(@build_directory_path)

# Checkout libphonenumber
system("svn checkout http://libphonenumber.googlecode.com/svn/trunk/ #{@build_directory_path}/libphonenumber")

# Checkout closure-library
system("git clone git://github.com/google/closure-library.git #{@build_directory_path}/closure-library")

# Download closure-compiler
system("curl -f -L http://dl.google.com/closure-compiler/compiler-latest.zip > #{@build_directory_path}/compiler-latest.zip")
system("unzip -o -d #{@build_directory_path} #{@build_directory_path}/compiler-latest.zip compiler.jar")

# Change to Build Directory
Dir.chdir(@build_directory_path)

# Compile libphonenumber
cmd = "python closure-library/closure/bin/build/closurebuilder.py " \
      "--root=closure-library "\
      "--namespace=\"i18n.phonenumbers.PhoneNumberUtil\" " \
      "--namespace=\"i18n.phonenumbers.AsYouTypeFormatter\" " \
      "--output_mode=compiled " \
      "--compiler_jar=compiler.jar " \
      "libphonenumber/javascript/i18n/phonenumbers/metadata.js " \
      "libphonenumber/javascript/i18n/phonenumbers/phonemetadata.pb.js " \
      "libphonenumber/javascript/i18n/phonenumbers/phonenumber.pb.js " \
      "libphonenumber/javascript/i18n/phonenumbers/phonenumberutil.js " \
      "libphonenumber/javascript/i18n/phonenumbers/asyoutypeformatter.js " \
      "> #{@libphonenumber_path}"

system(cmd)

# Remove Build Directory
FileUtils.rm_rf(@build_directory_path) if File.exists?(@build_directory_path)
