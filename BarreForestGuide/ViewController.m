//
//  ViewController.m
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 10/20/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()
@end

@implementation ViewController {
  GMSMapView        *mapView_;
  CLLocationManager *locationManager_;
  sqlite3           *mapDataDB_;
  NSMutableArray    *mapPolylines_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  if ([CLLocationManager locationServicesEnabled]) {
    if (locationManager_ == nil)
      locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager_.distanceFilter = 1;
    locationManager_.delegate = self;
    if ([locationManager_ respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [locationManager_ requestWhenInUseAuthorization];
    }
    [locationManager_ startUpdatingLocation];
  }

  GMSCameraPosition *camera = [ GMSCameraPosition cameraWithLatitude:44.150004 longitude:-72.469339 zoom:15];
  mapView_ =  [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView_.settings.compassButton = YES;
  mapView_.settings.myLocationButton = YES;
  //mapView_.myLocationEnabled = YES;
  
  //[mapView_ addObserver:self
  //           forKeyPath:@"myLocation"
  //              options:NSKeyValueObservingOptionNew
  //              context:NULL];

  NSString *mapDataDBName_ = [[NSBundle mainBundle]
                              pathForResource:@"BarreForestGuide"
                                       ofType:@"sqlite"];
  if (sqlite3_open([mapDataDBName_ UTF8String], &mapDataDB_) == SQLITE_OK) {
    NSString *mapobjQuerySQL =
        //[NSString stringWithFormat:@"select trail_id,lattitude,longitude from trail, coordinate, trail_difficulty where trail_id=trail.id and difficulty_id=trail_difficulty.id and english_difficulty in (\"Easy\",\"Moderate\",\"Walking\") order by trail_id, seq;"];
        [NSString stringWithFormat:@"select trail_id,lattitude,longitude from coordinate order by trail_id, seq;"];
    sqlite3_stmt *mapobjQueryStmt = nil;
    if (sqlite3_prepare_v2(mapDataDB_, [mapobjQuerySQL UTF8String], -1, &mapobjQueryStmt, NULL) == SQLITE_OK) {
      GMSMutablePath *trailpath = nil;
      int prev_trail_id = -1;
      while(sqlite3_step(mapobjQueryStmt) == SQLITE_ROW) {
        int trail_id = sqlite3_column_int(mapobjQueryStmt, 0);
        double lattitude = sqlite3_column_double(mapobjQueryStmt, 1);
        double longitude = sqlite3_column_double(mapobjQueryStmt, 2);
        //NSLog(@"trail_id %d (%f, %f)", trail_id, lattitude, longitude);
        if (prev_trail_id != trail_id) {
          if (trailpath && ([trailpath count]>1)) {
            GMSPolyline *trailpoly = [GMSPolyline polylineWithPath:trailpath];
            trailpoly.map = mapView_;
            //NSLog(@"Putting Polyline on the map");
          }
          trailpath = [GMSMutablePath path];
          prev_trail_id = trail_id;
        }
        [trailpath addCoordinate:CLLocationCoordinate2DMake(lattitude, longitude)];
      }
      if (trailpath && ([trailpath count]>1)) {
        GMSPolyline *trailpoly = [GMSPolyline polylineWithPath:trailpath];
        trailpoly.map = mapView_;
      }
      sqlite3_finalize(mapobjQueryStmt);
    } else
      NSLog(@"Failed to query database for Polyline points!");
  } else
    NSLog(@"Failed to open database!");
  
  self.view = mapView_;
  
  //dispatch_async(dispatch_get_main_queue(), ^{
  //    mapView_.myLocationEnabled = YES;
  //});
}

- (void)locationManager:(CLLocationManager*)manager
     didUpdateLocations:(NSArray*)locations
{
  CLLocation* location = [locations lastObject];
  NSDate *locDate = location.timestamp;
  NSTimeInterval age = [locDate timeIntervalSinceNow];
  if (abs(age) < 15.0) {
    GMSCameraUpdate *locUpdate = [GMSCameraUpdate setTarget:location.coordinate zoom:17];
    //[mapView_ animateWithCameraUpdate:locUpdate];
  }
  NSLog(@"Got a new location update");
}

- (void)locationManager:(CLLocationManager*)manager
       didFailWithError:(NSError*)error
{
  NSLog(@"Got a location error");
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  if (mapDataDB_)
    sqlite3_close(mapDataDB_);

  //[mapView_ removeObserver:self
  //              forKeyPath:@"myLocation"
  //                 context:NULL];
}

@end
