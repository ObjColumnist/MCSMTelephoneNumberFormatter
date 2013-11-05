//
//  MCSMTelephoneNumberFormatter.m
//
//  Copyright 2013 Square Bracket Software Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MCSMTelephoneNumberFormatter.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MCSMTelephoneNumberFormatter ()

@property (nonatomic, assign) JSGlobalContextRef JSContext;

#pragma mark -
#pragma mark - Internal

#pragma mark -
#pragma mark - JavaScriptCore Conversions

+ (NSString *)_escapedTelephoneNumberForTelephoneNumber:(NSString *)telephoneNumber;
+ (NSString *)_PNFFormatForFormat:(MCSMTelephoneNumberFormatterFormat)format;


#pragma mark -
#pragma mark - JavaScriptCore

- (void)_setupJSContext;
- (void)_evaluateScriptString:(NSString *)scriptString;
- (NSString *)_stringByEvaluatingScriptString:(NSString *)scriptString;
- (BOOL)_boolByEvaluatingScriptString:(NSString *)scriptString;

@end

@implementation MCSMTelephoneNumberFormatter

@synthesize JSContext = _JSContext;

+ (instancetype)mainThreadPartialNationalFormatTelephoneNumberFormatter{
    static MCSMTelephoneNumberFormatter *mainThreadNationalPartialTelephoneNumberFormatter = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        mainThreadNationalPartialTelephoneNumberFormatter = [[MCSMTelephoneNumberFormatter alloc] init];
        mainThreadNationalPartialTelephoneNumberFormatter.allowsPartialTelephoneNumbers = YES;
    });
    return mainThreadNationalPartialTelephoneNumberFormatter;
}

+ (instancetype)telephoneNumberFormatter{
    return [[MCSMTelephoneNumberFormatter alloc] init];
}

#pragma mark -
#pragma mark - Initialization

- (id)init{

    if ((self = [super init])) {
        [self setCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        [self _setupJSContext];
    }
    return self;
}

#pragma mark -
#pragma mark - Memory Management

- (void)dealloc{
    JSGlobalContextRelease([self JSContext]);
}

#pragma mark -
#pragma mark - NSFormatter

- (NSString *)stringForObjectValue:(id)objectValue{

    NSString *result = nil;

    if([objectValue isKindOfClass:[NSString class]])
    {
        result = objectValue;
    }

    return result;
}

- (BOOL)getObjectValue:(out id *)objectValue
             forString:(NSString *)string
      errorDescription:(out NSString **)errorDescription{

    *objectValue = [self telephoneNumberFromString:string];

    if([string length])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -
#pragma mark - Formatting

- (NSString *)telephoneNumberFromString:(NSString *)string{

    NSString *result = nil;

    string = [MCSMTelephoneNumberFormatter _escapedTelephoneNumberForTelephoneNumber:string];

    if ([string length] > 0)
    {
        if ([self allowsPartialTelephoneNumbers])
        {
            if((self.validatesTelephoneNumbers && [self isPossibleTelephoneNumber:string])
               || !self.validatesTelephoneNumbers)
            {
                NSString *scriptString =
                @"function formatAsYouTypeNumber(input,countryCode) {\
                var result = null;\
                var formatter = new i18n.phonenumbers.AsYouTypeFormatter(countryCode);\
                for (var i = 0; i < input.length; i++) {\
                result = formatter.inputDigit(input.charAt(i));\
                }\
                return result;\
                }\
                formatAsYouTypeNumber(\"%1$@\",\"%2$@\");";
                scriptString = [NSString stringWithFormat:scriptString, string, [self countryCode]];
                result = [self _stringByEvaluatingScriptString:scriptString];
            }

        }
        else
        {
            if((self.validatesTelephoneNumbers && [self isValidTelephoneNumber:string])
               || !self.validatesTelephoneNumbers)
            {
                NSString *PNFFormat = [MCSMTelephoneNumberFormatter _PNFFormatForFormat:self.format];

                NSString *scriptString =
                @"function formatNumber(input,countryCode) {\
                var PNF = i18n.phonenumbers.PhoneNumberFormat;\
                var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();\
                var number = phoneUtil.parseAndKeepRawInput(input,countryCode);\
                var region = phoneUtil.getRegionCodeForNumber(number);\
                var type = (region == countryCode || region == null) ? PNF.%3$@ : PNF.INTERNATIONAL;\
                return phoneUtil.format(number, type);\
                }\
                formatNumber(\"%1$@\", \"%2$@\");";

                scriptString = [NSString stringWithFormat:scriptString, string, [self countryCode], PNFFormat];
                result = [self _stringByEvaluatingScriptString:scriptString];
            }
        }

    }

    return result;
}

- (NSString *)stringFromTelephoneNumber:(NSString *)telephoneNumber{
    return telephoneNumber;
}

#pragma mark -
#pragma mark - Validation

- (BOOL)isPossibleTelephoneNumber:(NSString *)telephoneNumber{

    BOOL result = NO;

    telephoneNumber = [MCSMTelephoneNumberFormatter _escapedTelephoneNumberForTelephoneNumber:telephoneNumber];

    if([telephoneNumber length])
    {
        NSString *scriptString =
        @"function isPossibleNumber(input,countryCode) {\
        var PNF = i18n.phonenumbers.PhoneNumberFormat;\
        var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();\
        var number = phoneUtil.parseAndKeepRawInput(input,countryCode);\
        return phoneUtil.isPossibleNumber(number);\
        }\
        isPossibleNumber(\"%1$@\", \"%2$@\");";

        scriptString = [NSString stringWithFormat:scriptString, telephoneNumber, [self countryCode]];
        result = [self _boolByEvaluatingScriptString:scriptString];
    }

    return result;
}

- (BOOL)isValidTelephoneNumber:(NSString *)telephoneNumber{

    BOOL result = NO;

    telephoneNumber = [MCSMTelephoneNumberFormatter _escapedTelephoneNumberForTelephoneNumber:telephoneNumber];

    if([telephoneNumber length])
    {
        NSString *scriptString =
        @"function isValidNumber(input,countryCode) {\
        var PNF = i18n.phonenumbers.PhoneNumberFormat;\
        var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();\
        var number = phoneUtil.parseAndKeepRawInput(input, countryCode);\
        return phoneUtil.isValidNumber(number);\
        }\
        isValidNumber(\"%1$@\", \"%2$@\");";

        scriptString = [NSString stringWithFormat:scriptString, telephoneNumber, [self countryCode]];
        result = [self _boolByEvaluatingScriptString:scriptString];
    }

    return result;
}

#pragma mark -
#pragma mark - Geocoding

- (NSString *)countryCodeForTelephoneNumber:(NSString *)telephoneNumber{

    NSString *result = nil;

    telephoneNumber = [MCSMTelephoneNumberFormatter _escapedTelephoneNumberForTelephoneNumber:telephoneNumber];

    if([telephoneNumber length])
    {
        NSString *scriptString =
        @"function countryCodeForNumber(input,countryCode) {\
        var PNF = i18n.phonenumbers.PhoneNumberFormat;\
        var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();\
        var number = phoneUtil.parseAndKeepRawInput(input, countryCode);\
        return phoneUtil.getRegionCodeForNumber(number);\
        }\
        countryCodeForNumber(\"%1$@\",\"%2$@\");";

        scriptString = [NSString stringWithFormat:scriptString, telephoneNumber, [self countryCode]];
        result = [self _stringByEvaluatingScriptString:scriptString];
    }

    return result;
}

#pragma mark -
#pragma mark - Internal

#pragma mark -
#pragma mark - JavaScriptCore Conversions

+ (NSString *)_escapedTelephoneNumberForTelephoneNumber:(NSString *)telephoneNumber{
    return [telephoneNumber stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

+ (NSString *)_PNFFormatForFormat:(MCSMTelephoneNumberFormatterFormat)format{

    NSString *PNFFormat = nil;

    if(format == MCSMTelephoneNumberFormatterFormatNational)
    {
        PNFFormat = @"NATIONAL";
    }
    else if(format == MCSMTelephoneNumberFormatterFormatInternational)
    {
        PNFFormat = @"INTERNATIONAL";
    }
    else if(format == MCSMTelephoneNumberFormatterFormatE164)
    {
        PNFFormat = @"E164";
    }

    return PNFFormat;
}

#pragma mark -
#pragma mark - JavaScriptCore

- (void)_setupJSContext{

    NSURL *libphonenumberURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"libphonenumber" withExtension:@"js"];

    NSAssert([[libphonenumberURL path] length], @"libphonenumber.js not found");

    NSString *libphonenumberScriptString = [NSString stringWithContentsOfURL:libphonenumberURL
                                                                usedEncoding:NULL
                                                                       error:NULL];

    JSGlobalContextRef context = JSGlobalContextCreate(NULL);

    self.JSContext = context;

    [self _evaluateScriptString:libphonenumberScriptString];
}

- (void)_evaluateScriptString:(NSString *)scriptString{
    JSStringRef string = JSStringCreateWithCFString((__bridge CFStringRef)scriptString);

    JSEvaluateScript([self JSContext], string, NULL, NULL, 0, NULL);

    JSStringRelease(string);
}

- (NSString *)_stringByEvaluatingScriptString:(NSString *)scriptString{

    NSString *result = nil;

    JSStringRef string = JSStringCreateWithCFString((__bridge CFStringRef)scriptString);

    JSValueRef exception = NULL;
    JSValueRef value = JSEvaluateScript([self JSContext], string, NULL, NULL, 0, &exception);

    JSStringRelease(string);

    if (!exception)
    {
        JSStringRef resultString = JSValueToStringCopy([self JSContext], value, &exception);

        result = (__bridge_transfer NSString *)JSStringCopyCFString(kCFAllocatorDefault, resultString);

        JSStringRelease(resultString);
    }

    return result;
}

- (BOOL)_boolByEvaluatingScriptString:(NSString *)scriptString{

    BOOL result = NO;

    JSStringRef string = JSStringCreateWithCFString((__bridge CFStringRef)scriptString);

    JSValueRef exception = NULL;
    JSValueRef value = JSEvaluateScript([self JSContext], string, NULL, NULL, 0, &exception);

    JSStringRelease(string);

    if (!exception)
    {
        result = JSValueToBoolean([self JSContext], value);
    }

    return result;
}

@end
