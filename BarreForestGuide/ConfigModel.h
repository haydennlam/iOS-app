//
//  ConfigModel.h
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 11/17/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ConfigModel : NSObject <NSCoding>

@property BOOL            mapTracksGPS;
@property GMSMapViewType  mapType;

- (id) initFromDefaults;
- (void) saveToDefaults;

@end
