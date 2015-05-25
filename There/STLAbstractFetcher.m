//
//  STLAbstractFetcher.m
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLAbstractFetcher.h"

@implementation STLAbstractFetcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:@"AbstractClassException" format:@"You should not initialize this base class directly"];
    }
    return self;
}

- (STLAPIHandler *)api {
    return [STLAPIHandler sharedInstance];
}

@end
