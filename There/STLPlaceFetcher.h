//
//  STLPlaceFetcher.h
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

@import Foundation;
#import "STLAbstractFetcher.h"

/**
 Stores request-related data like an NSURL- or NSFetchRequest
 */
@interface STLPlaceRequest : NSObject
/// implicit region
@property (assign, nonatomic) MKMapRect mapRect;
/// explicit location
@property (strong, nonatomic) CLLocation *location;
/// plain text search query
@property (copy, nonatomic) NSString *queryString;

// TODO: filters, sorting, etc.
// X-Mobility-Mode
@end



@protocol STLPlaceRequestProtocol <NSObject>

- (void)searchSuggestionsForQuery:(STLPlaceRequest *)request complete:(void (^)(NSArray *suggestions, NSError *error))completionBlock;

/**
 Fetch places specified in the request
 */
- (void)searchPlacesWithQuery:(STLPlaceRequest*)request complete:(void (^)(NSArray *items, NSError *error))completionBlock;
@end


@interface STLPlaceFetcher : STLAbstractFetcher <STLPlaceRequestProtocol>
@end
