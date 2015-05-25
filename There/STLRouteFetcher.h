//
//  STLRouteFetcher.h
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLAbstractFetcher.h"


@interface STLRouteRequest : NSObject
/// Array of CLLocations defining the waypoints
@property (strong, nonatomic) NSArray *waypoints;
@property (strong, nonatomic) NSDictionary *parameters;
@end


@protocol STLRouteRequestProtocol <NSObject>
/// HERE's: calculateroute resource
- (void)routeWithRequest:(STLRouteRequest *)request complete:(void (^)(NSArray *navPoints, NSError *error))completionBlock;
@end


@interface STLRouteFetcher : STLAbstractFetcher <STLRouteRequestProtocol>
@end
