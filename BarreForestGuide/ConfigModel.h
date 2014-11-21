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

+ (ConfigModel*)getConfigModel;
- (id) initFromDefaults;
- (void) saveToDefaults;

@end

/* vim: set ai si sw=2 ts=80 ru: */
