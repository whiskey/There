//
//  STLAbstractFetcher.h
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

@import MapKit;
#import <Foundation/Foundation.h>
#import "STLAPIHandler.h"


@interface STLAbstractFetcher : NSObject
@property (strong, nonatomic, readonly) STLAPIHandler *api;
@end
