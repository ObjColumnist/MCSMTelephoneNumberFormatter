# MCSMTelephoneNumberFormatter

`MCSMTelephoneNumberFormatter` is a subclass of `NSFormatter` that formats and validates Telephone Numbers in National, International and E164 formats. It achieves this by wrapping a compiled version of Google's [libphonenumber](https://code.google.com/p/libphonenumber/) using the `JavaScriptCore.framework`.

##Xcode

To use `MCSMTelephoneNumberFormatter` you need to add `MCSMTelephoneNumberFormatter.h` and `MCSMTelephoneNumberFormatter.m` to your project, link against `JavaScriptCore.framework` and copy *__(not compile)__* `libphonenumber.js` into your application's bundle.

##Configuration

You can configure `MCSMTelephoneNumberFormatter` using the 3 properties:

###Country Code

```objc
@property (nonatomic, copy) NSString *countryCode;
```

The country code is automatically set based on NSLocale's current locale. This is used to convert National Telephone Numbers to International Telephone Numbers.

###Format

```objc
@property (nonatomic, assign) MCSMTelephoneNumberFormatterFormat format;
```

The formats are defined as:

```objc
typedef NS_ENUM(NSUInteger, MCSMTelephoneNumberFormatterFormat){
	MCSMTelephoneNumberFormatterFormatNational,
	MCSMTelephoneNumberFormatterFormatInternational,
	MCSMTelephoneNumberFormatterFormatE164
};
```

This is used to set the format of the Telephone Number returned from `telephoneNumberFromString:`.

###Partial Telephone Numbers

```objc
@property (nonatomic, assign) BOOL allowsPartialTelephoneNumbers;
```

Setting this to `YES` means that partial Telephones Numbers will be formatted, this is useful if you want to format a Telephone Number as a user enters it.

##Example

```objc
MCSMTelephoneNumberFormatter *formatter = [[MCSMTelephoneNumberFormatter alloc] init];

[formatter setCountryCode:@"US"];
[formatter setFormat:MCSMTelephoneNumberFormatterFormatInternational];

NSLog(@"%@", [formatter telephoneNumberFromString:@"0800 048 0408"]);
```

This outputs:
```
+1 08000480408
```

##Recompiling libphonenumber.js

To recompile `libphonenumber.js` run `compile_libphonenumber.rb` from the command line:

```
ruby compile_libphonenumber.rb
```

This requires an Internet Connection, in addition to Ruby, Python and Java being installed on your system.

##Requirements

- Automatic Reference Counting (ARC)
- JavaScriptCore.framework

##License

Apache License Version 2.0 