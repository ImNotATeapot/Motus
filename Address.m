//
//  Address.m
//  motus
//
//  Created by Patriya Piyawiroj on 6/23/2560 BE.
//  Copyright © 2560 Patriya Piyawiroj. All rights reserved.
//

#import "Address.h"
#import "Utility.h"

#define ID @"addr_id"
#define NAME @"addr_name"
#define STREET @"addr_street"
#define ADDRESS_LINE1 @"addr_addr_line1"
#define ADDRESS_LINE2 @"addr_addr_line2"
#define DISTRICT @"addr_district"
#define SUB_DISTRICT @"addr_sub_district"
#define PROVINCE @"addr_province"
//#define STATE @"addr_state"
#define CITY @"addr_city"
#define COUNTRY @"addr_country"
#define POSTAL_CODE @"addr_postal_code"
#define EMAIL @"addr_email"
#define WEBSITE @"addr_website"
#define FAX @"addr_fax"
#define MOBILE @"addr_mobile"
#define PHONE1 @"addr_phone1"
#define PHONE2 @"addr_phone2"
#define LATITUDE @"addr_latitude"
#define LONGITUDE @"addr_longitude"
#define IMAGE @"addr_image"
#define TYPE @"addr_type"
#define ACCOUNT_ID @"addr_acct_id"
#define IS_NEW @"addr_is_new"
#define IS_SYNC @"addr_is_sync"
#define EXTERNAL_ID @"addr_ext_id"
#define COUNT_PER_RECORD @"count_per_record"
#define ACCOUNT_NAME @"acct_name"
#define IMG_MODIFIED_TIME @"addr_img_modified_time"
#define COLOR @"addr_color"

@implementation Address

+ (NSString *)tableName {
    return @"Address";
}

+ (NSString *)idColumn {
    return ID;
}

+ (NSString *)externalIdColumn {
    return EXTERNAL_ID;
}

+ (NSString *)nameColumn {
    return NAME;
}

+ (NSString *)joinString {
    return [NSString stringWithFormat:@"JOIN %@ ON %@=%@", [Account tableName], ACCOUNT_ID, [Account idColumn]];
}

+ (Address *)createNew {
    Address *address = [[Address alloc] init];
    address.identifier = [Utility generateUniqueId];
    address.contacts = [NSMutableArray array];
    address.isNew = YES;
    return address;
}

+ (int) billToAddressType {
    return ADDRESS_TYPE_BILL_TO;
}

+ (int) shipToAddressType {
    return ADDRESS_TYPE_SHIP_TO;
}

+ (id)decode:(NSDictionary *)dict {
    Address *address = [[Address alloc] init];
    
    address.identifier = dict[ID];
    address.name = dict[NAME];
    address.street = dict[STREET];
    address.addressLine1 = dict[ADDRESS_LINE1];
    address.addressLine2 = dict[ADDRESS_LINE2];
    address.district = dict[DISTRICT];
    address.subDistrict = dict[SUB_DISTRICT];
    address.province = dict[PROVINCE];
    //address.state = dict[STATE];
    address.city = dict[CITY];
    address.country = dict[COUNTRY];
    address.postalCode = dict[POSTAL_CODE];
    address.email = dict[EMAIL];
    address.website = dict[WEBSITE];
    address.fax = dict[FAX];
    address.mobile = dict[MOBILE];
    address.phone1 = dict[PHONE1];
    address.phone2 = dict[PHONE2];
    address.latitude = ![dict[LATITUDE] isKindOfClass:[NSNull class]] ? [dict[LATITUDE] doubleValue] : 0;
    address.longitude = ![dict[LONGITUDE] isKindOfClass:[NSNull class]] ? [dict[LONGITUDE] doubleValue] : 0;
    address.image = dict[IMAGE];
    address.type = [dict[TYPE] longValue];
    address.accountId = dict[ACCOUNT_ID];
    address.isNew = [dict[IS_NEW] boolValue];
    address.isSync = [dict[IS_SYNC] boolValue];
    address.externalId = dict[EXTERNAL_ID];
    address.countPerRecord = [dict[COUNT_PER_RECORD] longValue];
    address.accountName = dict[ACCOUNT_NAME];
    address.imageModifiedTime = [dict[IMG_MODIFIED_TIME] longValue];
    
    address.color = dict[COLOR];

    //address.parentAccount = [Account decode:dict];
    
    return address;
} 

- (NSDictionary *)encode {
    return @{ ID : self.identifier,
              NAME : self.name != nil ? self.name : @"",
              STREET : self.street != nil ? self.street : @"",
              ADDRESS_LINE1 : self.addressLine1 != nil ? self.addressLine1 : @"",
              ADDRESS_LINE2 : self.addressLine2 != nil ? self.addressLine2 : @"",
              DISTRICT : self.district != nil ? self.district : @"",
              SUB_DISTRICT : self.subDistrict != nil ? self.subDistrict : @"",
              PROVINCE : self.province != nil ? self.province : @"",
              //STATE : self.state != nil ? self.state : @"",
              CITY : self.city != nil ? self.city : @"",
              COUNTRY : self.country != nil ? self.country : @"",
              POSTAL_CODE : self.postalCode != nil ? self.postalCode : @"",
              EMAIL : self.email != nil ? self.email : @"",
              WEBSITE : self.website != nil ? self.website : @"",
              FAX : self.fax != nil ? self.fax : @"",
              MOBILE : self.mobile != nil ? self.mobile : @"",
              PHONE1 : self.phone1 != nil ? self.phone1 : @"",
              PHONE2 : self.phone2 != nil ? self.phone2 : @"",
              LATITUDE : @(self.latitude),
              LONGITUDE : @(self.longitude),
              IMAGE : self.image == nil ? @"" : self.image,
              TYPE : @(self.type),
              ACCOUNT_ID : self.accountId != nil ? self.accountId : @"",
              IS_NEW : @(self.isNew),
              IS_SYNC : @(self.isSync),
              EXTERNAL_ID : self.externalId != nil ? self.externalId : @"",
              IMG_MODIFIED_TIME : @(self.imageModifiedTime),
              COLOR : self.color != nil ? self.color : @""
              };
}

+ (NSString *)typeColumn {
    return TYPE;
}

+ (NSString *)accountIdColumn {
    return ACCOUNT_ID;
}

@end
