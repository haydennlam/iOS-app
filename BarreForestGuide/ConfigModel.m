//
//  ConfigModel.m
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 11/17/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import "ConfigModel.h"

@implementation ConfigModel

#pragma mark - NSCoding

- (id) init {
  if (self = [super init]) {
    self.mapTracksGPS = false;
    self.mapType = kGMSTypeNormal;
  }
  return(self);
}

+ (ConfigModel*)getConfigModel {
  static ConfigModel *singleton = nil;
  static dispatch_once_t gate;
  dispatch_once(&gate, ^{ singleton = [[ConfigModel alloc] initFromDefaults]; });
  return(singleton);
}

- (id) initWithCoder:(NSCoder*)decoder {
  self.mapTracksGPS = [decoder decodeBoolForKey:@"mapTracksGPS"];
  self.mapType = [decoder decodeIntForKey:@"mapType"];
  return(self);
}

- (id) initFromDefaults {
  NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"config"];
  if (data) {
    self = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  } else {
    self = [self init];
  }
  NSLog(@"initFromDefaults: mapTracksGPS=%d, mapType=%d", self.mapTracksGPS, self.mapType);
  return(self);
}

- (void) encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeBool:_mapTracksGPS forKey:@"mapTracksGPS"];
  [encoder encodeInt:_mapType forKey:@"mapType"];
}

- (void) saveToDefaults {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"config"];
  NSLog(@"saveToDefaults: mapTracksGPS=%d, mapType=%d", self.mapTracksGPS, self.mapType);
}

@end

/* vim: set ai si sw=2 ts=80 ru: */
