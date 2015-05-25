//
//  STLAPIHandler.h
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface STLAPIHandler : AFHTTPRequestOperationManager

+ (void)setAppID:(NSString *)appID appCode:(NSString *)appCode;
+ (instancetype)sharedInstance;

@end
