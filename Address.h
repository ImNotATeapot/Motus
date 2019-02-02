//
//  Address.h
//  motus
//
//  Created by Patriya Piyawiroj on 6/23/2560 BE.
//  Copyright © 2560 Patriya Piyawiroj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Contact.h"
#import "Account.h"

#define ADDRESS_TYPE_BILL_TO 1
#define ADDRESS_TYPE_SHIP_TO 2

@interface Address : NSObject <Model>

+ (NSString *)nameColumn;
+ (Address *)createNew;

+ (int) billToAddressType;
+ (int) shipToAddressType;

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *street;
@property (nonatomic, retain) NSString *addressLine2;
@property (nonatomic, retain) NSString *subDistrict;
//@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *postalCode;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *fax;
@property (nonatomic, retain) NSString *mobile;
@property (nonatomic, retain) NSString *phone1;
@property (nonatomic, retain) NSString *phone2;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *externalId;
@property (nonatomic, retain) NSString *district;
@property (nonatomic, retain) NSString *addressLine1;
@property double latitude;
@property double longitude;
@property (nonatomic, retain) NSString *image;
@property NSInteger imageModifiedTime;
@property NSInteger type;
@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) NSString *accountName;
@property NSInteger countPerRecord;
@property (nonatomic, retain) NSString *color;

//@property (nonatomic, retain) Account *parentAccount;
@property (nonatomic, retain) NSMutableArray *contacts;

@property BOOL isNew;
@property BOOL isSync;

+ (NSString *)typeColumn;
+ (NSString *)accountIdColumn;

@end
