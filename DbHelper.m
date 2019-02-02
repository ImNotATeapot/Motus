//
//  DbHelper.m
//  motus
//
//  Created by Patriya Piyawiroj on 6/23/2560 BE.
//  Copyright © 2560 Patriya Piyawiroj. All rights reserved.
//

#import "DbHelper.h"
#import <sqlite3.h>
#import "NSDate+Extension.h"
#import "VisitActivityPlan.h"
#import "Utility.h"

#define BUNDLE_DATABASE_FILE_NAME @"data"
#define BUNDLE_DATABASE_FILE_EXTENSION @"sqlite"
#define DATABASE_FILE @"data.sqlite"

@interface DbHelper ()
{
    sqlite3 *database;
}
@end

static DbHelper *dbHelper;

@implementation DbHelper

+ (DbHelper *)instance {
    if (dbHelper == nil) {
        dbHelper = [[DbHelper alloc] init];
    }
    return dbHelper;
}

- (id)init {
    self = [super init];
    
    if (self) {
        if (![self databaseFileExists]) {
            [self createDatabaseFile];
        }
        
        NSLog(@"DB = %@", [self databasePath]);
        
        [self open];
    }
    
    return self;
}

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark - Database

-(void)editTable{
    
    NSArray *addresses = [self getAddressListSorted:nil groupBy:@"addr_province" orderBy:@"addr_province"];
    int count = 0;
    
    for (Address *address in addresses) {
        int r = 45 * count%4 + 70;
        int g = 45 * count%16/4 + 70;
        int b = 45 * count/16 + 70;
        
        NSString *province = address.province;
        NSString *colorHex = [NSString stringWithFormat:@"%02X%02X%02X", r,g,b];
        
        [self queryNoParam:[NSString stringWithFormat:@"UPDATE Address SET addr_color = '%@' WHERE addr_province = '%@'", colorHex, province]];

        count++;
        if (count == 64) {
            count = 0;
        }
    }

//    [self queryNoParam:@"UPDATE Address SET addr_color = 'FFFFFF'"];
//    NSArray *addressList = [self selectAllModels:[Address class]];
//    for (Address *address in addressList) {
//        NSLog(@"%@", address.color);
//    }
}

- (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return [NSString pathWithComponents:@[basePath, DATABASE_FILE]];
}

- (BOOL)databaseFileExists {
    NSString *dbPath = [self databasePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
}

- (void)createDatabaseFile {
    NSString *bundleDbPath = [[NSBundle mainBundle] pathForResource:BUNDLE_DATABASE_FILE_NAME ofType:BUNDLE_DATABASE_FILE_EXTENSION];
    NSString *dbPath = [self databasePath];
    [[NSFileManager defaultManager] copyItemAtPath:bundleDbPath toPath:dbPath error:nil];
}

- (void)open {
    NSString *dbPath = [self databasePath];

    if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
}

- (void)reset {
    [[NSFileManager defaultManager] removeItemAtPath:[self databasePath] error:nil];
    [self createDatabaseFile];
    [self open];
}

- (NSArray *)queryNoParam:(NSString *)sql {
    return [self query:sql, nil];
}

BOOL numberIsFraction(NSNumber *number) {
    double dValue = [number doubleValue];
    if (dValue < 0.0)
        return (dValue != ceil(dValue));
    else
        return (dValue != floor(dValue));
}

- (NSArray *)query:(NSString *)sql, ... {
    NSMutableArray *arguments = [NSMutableArray array];
    va_list argumentList;
    va_start(argumentList, sql);
    for (id eachObject; (eachObject = va_arg(argumentList, id)); ) {
        [arguments addObject: eachObject];
    }
    va_end(argumentList);
    
//    NSLog(@"query: %@ (%@)", sql, arguments);
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        for (int i = 0; i < arguments.count; i++) {
            id argument = arguments[i];
            if ([argument isKindOfClass:[NSString class]]) {
                sqlite3_bind_text(statement, i + 1, [argument UTF8String], (int)strlen([argument UTF8String]), SQLITE_STATIC);
            } else if ([argument isKindOfClass:[NSNumber class]]) {
                if (numberIsFraction(argument)) {
                    sqlite3_bind_double(statement, i + 1, [argument doubleValue]);
                } else {
                    sqlite3_bind_int64(statement, i + 1, [argument longValue]);
                }
            } else {
                sqlite3_bind_null(statement, i + 1);
            }
        }
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *objDict = [NSMutableDictionary dictionary];
            for (int i = 0; i < sqlite3_column_count(statement); i++) {
                switch (sqlite3_column_type(statement, i)) {
                    case SQLITE_INTEGER: {
                        NSInteger value = sqlite3_column_int64(statement, i);
                        objDict[[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]] = [NSNumber numberWithLong:value];
                    }
                        break;
                    case SQLITE_FLOAT: {
                        double value = sqlite3_column_double(statement, i);
                        objDict[[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]] = [NSNumber numberWithDouble:value];
                    }
                        break;
                    case SQLITE_TEXT: {
                        char *value = (char *) sqlite3_column_text(statement, i);
                        objDict[[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]] = [[NSString alloc] initWithUTF8String:value];
                    }
                        break;
                    case SQLITE_NULL: {
                        objDict[[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]] = @"";
                    }
                        break;
                    default: {
//                        NSLog(@"column = %d", sqlite3_column_type(statement, i));
                    }
                        break;
                }
            }
            [retval addObject:objDict];
        }
        sqlite3_finalize(statement);
    }
    return retval;
}

- (NSArray *)queryValue:(NSString *)sql, ... {
    NSMutableArray *arguments = [NSMutableArray array];
    va_list argumentList;
    va_start(argumentList, sql);
    for (id eachObject; (eachObject = va_arg(argumentList, id)); ) {
        [arguments addObject: eachObject];
    }
    va_end(argumentList);
    
//    NSLog(@"query: %@ (%@)", sql, arguments);
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        for (int i = 0; i < arguments.count; i++) {
            id argument = arguments[i];
            if ([argument isKindOfClass:[NSString class]]) {
                sqlite3_bind_text(statement, i + 1, [argument UTF8String], (int)strlen([argument UTF8String]), SQLITE_STATIC);
            } else if ([argument isKindOfClass:[NSNumber class]]) {
                if (numberIsFraction(argument)) {
                    sqlite3_bind_double(statement, i + 1, [argument doubleValue]);
                } else {
                    sqlite3_bind_int64(statement, i + 1, [argument longValue]);
                }
            } else {
                sqlite3_bind_null(statement, i + 1);
            }
        }
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            for (int i = 0; i < sqlite3_column_count(statement); i++) {
                switch (sqlite3_column_type(statement, i)) {
                    case SQLITE_INTEGER: {
                        NSInteger value = sqlite3_column_int64(statement, i);
                        [retval addObject:[NSNumber numberWithLong:value]];
                    }
                        break;
                    case SQLITE_FLOAT: {
                        double value = sqlite3_column_double(statement, i);
                        [retval addObject:[NSNumber numberWithDouble:value]];
                    }
                        break;
                    case SQLITE_TEXT: {
                        char *value = (char *) sqlite3_column_text(statement, i);
                        [retval addObject:[[NSString alloc] initWithUTF8String:value]];
                    }
                        break;
                }
            }
            
        }
        sqlite3_finalize(statement);
    }
    return retval;
}

- (BOOL)insertOrReplaceInto:(NSString *)table params:(NSDictionary *)paramDict {
    NSMutableString *columeNameString = [NSMutableString stringWithString:@""];
    for (NSString *keyString in paramDict.allKeys) {
        if (![columeNameString isEqualToString:@""]) {
            [columeNameString appendString:@","];
        }
        [columeNameString appendString:keyString];
    }
    
    NSArray *arguments = paramDict.allValues;
    NSMutableString *paramString = [NSMutableString stringWithString:@""];
    for (int i = 0; i < arguments.count; i++) {
        if (![paramString isEqualToString:@""]) {
            [paramString appendString:@","];
        }
        [paramString appendString:@"?"];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)", table, columeNameString, paramString];
    //NSLog(@"%@", sql);
    
//    NSLog(@"insert: %@ (%@)", sql, arguments);
    
    BOOL result = NO;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        for (int i = 0; i < arguments.count; i++) {
            id argument = arguments[i];
            if ([argument isKindOfClass:[NSString class]]) {
                sqlite3_bind_text(statement, i + 1, [argument UTF8String], (int)strlen([argument UTF8String]), SQLITE_STATIC);
            } else if ([argument isKindOfClass:[NSNumber class]]) {
                if (numberIsFraction(argument)) {
                    sqlite3_bind_double(statement, i + 1, [argument doubleValue]);
                } else {
                    sqlite3_bind_int64(statement, i + 1, [argument longValue]);
                }
            } else {
                sqlite3_bind_null(statement, i + 1);
            }
        }
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            result = YES;
        }
        sqlite3_finalize(statement);
    }
    
    return result;
}



#pragma mark - Address
- (NSArray *)selectModelAddressList:(Class<Model>)model where:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)column asc:(BOOL)isAsc  {
    NSArray *resultArray = [self queryNoParam:[NSString stringWithFormat:@"SELECT Address.addr_acct_id, Address.addr_id, Address.addr_name, Address.addr_latitude, Address.addr_longitude, Address.addr_province, Address.addr_district, Address.addr_color, COUNT(*) AS count_per_record FROM %@ %@ %@ %@",
                                               [model tableName],
                                               where == nil ? @"" : [NSString stringWithFormat:@"WHERE %@", where],
                                               groupBy == nil ? @"" : [NSString stringWithFormat:@"GROUP BY Address.%@", groupBy],
                                               column == nil ? @"" : [NSString stringWithFormat:@"ORDER BY Address.%@ %s", column, isAsc ? "ASC" : "DESC"]]];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSDictionary *resultDict in resultArray) {
        [results addObject:[model decode:resultDict]];
    }
    return results;
}

- (NSArray *)getAddressListSorted:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString*)orderBy {
    NSArray *addresses = [self selectModelAddressList:[Address class] where:where groupBy:groupBy orderBy:orderBy asc:YES];
    
    return addresses;
}

- (NSArray *)searchAddress:(NSString *)searchText where:(NSString *)where groupBy:(NSString*)groupBy orderBy:orderBy {
    NSArray *addresses = [self selectModelAddressList:[Address class] where:where groupBy:groupBy orderBy:orderBy asc:YES];
    return addresses;
}

- (NSArray *)selectModelAddressListFilter:(Class<Model>)model where:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)column asc:(BOOL)isAsc  {
    NSArray *resultArray = [self queryNoParam:[NSString stringWithFormat:@"SELECT Account.acct_name, Address.addr_acct_id, Address.addr_id, Address.addr_name, Address.addr_latitude, Address.addr_longitude, Address.addr_province, Address.addr_district FROM %@ INNER JOIN Account ON Account.acct_id=Address.addr_acct_id %@ %@ %@",
                                               [model tableName],
                                               where == nil ? @"" : [NSString stringWithFormat:@"WHERE %@", where],
                                               groupBy == nil ? @"" : [NSString stringWithFormat:@"GROUP BY %@", groupBy],
                                               column == nil ? @"" : [NSString stringWithFormat:@"ORDER BY %@ %s", column, isAsc ? "ASC" : "DESC"]]];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSDictionary *resultDict in resultArray) {
        [results addObject:[model decode:resultDict]];
    }
    return results;
}

- (NSArray *)searchAddressBranch:(NSString *)where groupBy:(NSString*)groupBy orderBy:orderBy {
    NSArray *addresses = [self selectModelAddressListFilter:[Address class] where:where groupBy:groupBy orderBy:orderBy asc:YES];
    return addresses;
}

- (NSArray *)selectModelAddressListToPinMap:(Class<Model>)model where:(NSString *)where  {
    NSArray *resultArray = [self queryNoParam:[NSString stringWithFormat:@"SELECT Address.addr_acct_id, Address.addr_id, Address.addr_name, Address.addr_latitude, Address.addr_longitude, Address.addr_color FROM %@ %@ ",
                                               [model tableName],
                                               where == nil ? @"WHERE Address.addr_latitude <> 0 AND Address.addr_longitude <> 0" : [NSString stringWithFormat:@"WHERE (Address.addr_latitude <> 0 AND Address.addr_longitude <> 0) AND %@", where]
                                               ]];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSDictionary *resultDict in resultArray) {
        [results addObject:[model decode:resultDict]];
    }
    return results;
}


- (NSArray *)getAllAddresses{
    NSArray *addresses = [self selectAllModels:[Address class]];
    return addresses;
}

- (NSArray *)getAllAddressesInAccount:(NSString *)accountId Type:(NSInteger)type{
    NSArray *addresses = [self selectModels:[Address class] where:[NSString stringWithFormat:@"addr_acct_id=\"%@\" AND addr_type= %ld", accountId, type]];
    return addresses;
}

- (NSArray *)getAddressesFromIdentifier:(NSString *)addressId{
    NSArray *addresses = [self selectModels:[Address class] where:[NSString stringWithFormat:@"addr_id=\"%@\"", addressId]];
    return addresses;
}

- (NSArray *)getAddressesFromNameAndLocation:(NSString *)addressName latitude:(NSString*)latitude longitude:(NSString*)longitude{
    NSArray *addresses = [self selectModels:[Address class] where:[NSString stringWithFormat:@"addr_name=\"%@\" AND addr_latitude=\"%@\" AND addr_longitude=\"%@\"", addressName, latitude, longitude]];
    return addresses;
}


@end
