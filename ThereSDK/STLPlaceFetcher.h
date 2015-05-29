//
//  STLPlaceFetcher.h
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

@import Foundation;
#import "STLAPIFetcher.h"

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



@interface STLLinkObject : NSObject
@property (copy, nonatomic) NSString *identifier;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

/// Reference URL to this link
@property (copy, nonatomic) NSString *href;
/// The label/description of this link
@property (copy, nonatomic) NSString *title;
/// String describing the vicinity of this link
@property (copy, nonatomic) NSString *vicinity;
/// The distance from the search reference point to this link
@property (assign, nonatomic) NSInteger distanceInMeters;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithIdentifier:(NSString *)identifier;
@end



@protocol STLPlaceRequestProtocol <NSObject>

- (void)searchSuggestionsForQuery:(STLPlaceRequest *)request complete:(void (^)(NSArray *suggestions, NSError *error))completionBlock;

/**
 Fetch places specified in the request
 */
- (void)searchPlacesWithQuery:(STLPlaceRequest*)request complete:(void (^)(NSArray *items, NSError *error))completionBlock;
@end


@interface STLPlaceFetcher : STLAPIFetcher <STLPlaceRequestProtocol>
- (instancetype)initWithAppID:(NSString *)appID appCode:(NSString *)appCode;
@end
