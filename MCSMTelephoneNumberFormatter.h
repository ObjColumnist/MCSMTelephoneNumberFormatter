//
//  MCSMTelephoneNumberFormatter.h
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

@import Foundation;

typedef NS_ENUM(NSUInteger, MCSMTelephoneNumberFormatterFormat){
    MCSMTelephoneNumberFormatterFormatNational,
    MCSMTelephoneNumberFormatterFormatInternational,
    MCSMTelephoneNumberFormatterFormatE164
};

typedef NS_ENUM(NSUInteger, MCSMTelephoneNumberFormatterTelephoneNumberType){
    MCSMTelephoneNumberFormatterTelephoneNumberTypeUnknown,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeFixedLine,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeMobile,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeFixedLineOrMobile,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeTollFree,
    MCSMTelephoneNumberFormatterTelephoneNumberTypePremiumRate,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeSharedCost,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeVoIP,
    MCSMTelephoneNumberFormatterTelephoneNumberTypePersonal,
    MCSMTelephoneNumberFormatterTelephoneNumberTypePager,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeUAN,
    MCSMTelephoneNumberFormatterTelephoneNumberTypeVoicemail
};

@interface MCSMTelephoneNumberFormatter : NSFormatter

@property (nonatomic, copy) NSString *countryCode; // 2 Letter Country Code e.g. US. Default is NSLocale's currentLocale countryCode.
@property (nonatomic, assign) MCSMTelephoneNumberFormatterFormat format; // Default is MCSMTelephoneNumberFormatterFormatNational.
@property (nonatomic, assign) BOOL allowsPartialTelephoneNumbers; // Default is NO. Setting this to YES means that partial telephone numbers will be formatted.
@property (nonatomic, assign) BOOL validatesTelephoneNumbers; // Default is NO. Setting this to YES means that telephone numbers are validated before formatting.
@property (nonatomic, assign) BOOL returnsInvalidString; // Default is NO. Setting this to YES means that the string is returned if it is invalid instead of nil.

+ (NSString *)partialNationalFormatTelephoneNumberFromString:(NSString *)string; // Reduces the overhead of alloc/init a MCSMTelephoneNumberFormatter when used on the Main Thread.

+ (instancetype)telephoneNumberFormatter;

#pragma mark -
#pragma mark - Formatting

- (NSString *)telephoneNumberFromString:(NSString *)string;
- (NSString *)stringFromTelephoneNumber:(NSString *)telephoneNumber;

#pragma mark -
#pragma mark - Telephone Number Type

- (MCSMTelephoneNumberFormatterTelephoneNumberType)telephoneNumberTypeForTelephoneNumber:(NSString *)telephoneNumber;

#pragma mark -
#pragma mark - Validation

- (BOOL)isPossibleTelephoneNumber:(NSString *)telephoneNumber; // Estimates if a telephone number is possible based on its length. This is significantly faster than isValidTelephoneNumber:.
- (BOOL)isValidTelephoneNumber:(NSString *)telephoneNumber;

#pragma mark -
#pragma mark - Geocoding

- (NSString *)countryCodeForTelephoneNumber:(NSString *)telephoneNumber; // Returns a 2 Letter Country Code e.g. US or nil.

@end
