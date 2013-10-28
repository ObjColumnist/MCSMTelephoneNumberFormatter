Pod::Spec.new do |s|
  s.name     = 'MCSMTelephoneNumberFormatter'
  s.version  = '1.0'
  s.summary  = 'A Telephone Number Formatter for iOS and OS X.'
  s.homepage = 'https://github.com/ObjColumnist/MCSMTelephoneNumberFormatter'
  s.author   = 'Spencer MacDonald'
  s.source   = { :git => 'https://github.com/ObjColumnist/MCSMTelephoneNumberFormatter.git'}
  s.license  = { :type => 'Apache', :file => 'LICENSE' }
  s.description = 'MCSMTelephoneNumberFormatter is a subclass of NSFormatter that formats and validates Telephone Numbers in National, International and E164 formats.'
  
  s.source_files = '*.{h,m}'
  s.requires_arc = true 
  s.framework = 'JavaScriptCore'
  s.resource = 'libphonenumber.js'
end