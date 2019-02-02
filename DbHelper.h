//
//  DbHelper.h
//  motus
//
//  Created by Patriya Piyawiroj on 6/23/2560 BE.
//  Copyright © 2560 Patriya Piyawiroj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Authentication.h"
#import "Address.h"
#import "LoginConfiguration.h"
#import "ImageToSync.h"

@interface DbHelper : NSObject

+ (DbHelper *)instance;

// Database
- (void)reset;
- (NSArray *)queryNoParam:(NSString *)sql;
- (NSArray *)query:(NSString *)sql, ...;
- (BOOL)insertOrReplaceInto:(NSString *)table params:(NSDictionary *)paramDict;
- (void)editTable;

//- (NSArray *)selectModels:(Class<Model>)model orderBy:(NSString *)column asc:(BOOL)isAsc;
- (NSArray *)selectModels:(Class<Model>)model where:(NSString *)where orderBy:(NSString *)column asc:(BOOL)isAsc;
- (void)updateModel:(Class<Model>)model fromId:(NSString *)fromId toId:(NSString *)toId;
- (void)updateModel:(Class<Model>)model serverId:(NSString *)serverId identifier:(NSString* )identifier;
- (void)updateModel:(Class<Model>)model column:(NSString *)column toValue:(NSString *)toValue identifier:(NSString *)identifier;
- (void)updateModel:(Class<Model>)model column:(NSString *)column fromValue:(NSString *)fromValue toValue:(NSString *)toValue;
- (void)updateModel:(Class<Model>)model column:(NSString *)column fromValue:(NSString *)fromValue toValue:(NSString *)toValue where:(NSString *)where;

// Address
- (NSArray *)getAllAddresses;
- (NSArray *)getAllAddressesInAccount:(NSString *)accountId Type:(NSInteger)type;
- (NSArray *)getAddressesFromIdentifier:(NSString *)addressId;
- (NSArray *)selectAllAddressImages;
- (NSArray *)searchAddress:(NSString *)searchText where:(NSString *)where groupBy:(NSString*)groupBy orderBy:orderBy;

@end
