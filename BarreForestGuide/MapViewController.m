//
//  MapViewController.m
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 10/20/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import "MapViewController.h"
#import <sqlite3.h>

@interface MapViewController ()
@end

@implementation MapViewController {
  GMSMapView        *mapView_;
  CLLocationManager *locationManager_;
  sqlite3           *mapDataDB_;
  NSMutableArray    *mapPolylines_;
}

@synthesize mapView;

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
  mapView_ =  [GMSMapView mapWithFrame:mapView.bounds camera:camera];
  mapView_.settings.compassButton = YES;
  mapView_.settings.myLocationButton = YES;
  //mapView_.mapType = kGMSTypeSatellite;
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
        [NSString stringWithFormat:@"select trail_id,lattitude,longitude from coordinates order by trail_id, rowid;"];
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

    NSString *POIQuerySQL =
        [NSString stringWithFormat:@"select name,type,lattitude,longitude,url from points_of_interest;"];
    sqlite3_stmt *POIQueryStmt = nil;
    if (sqlite3_prepare_v2(mapDataDB_, [POIQuerySQL UTF8String], -1, &POIQueryStmt, NULL) == SQLITE_OK) {
      while(sqlite3_step(POIQueryStmt) == SQLITE_ROW) {
        char *name = (char*)sqlite3_column_text(POIQueryStmt, 0);
        int type = sqlite3_column_int(POIQueryStmt, 1);
        double lattitude = sqlite3_column_double(POIQueryStmt, 2);
        double longitude = sqlite3_column_double(POIQueryStmt, 3);
        char *url = (char*)sqlite3_column_text(POIQueryStmt, 4);
        NSLog(@"POI: %s [%d] (%f, %f) - %s", name, type, lattitude, longitude, url);

        CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(lattitude, longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:pos];
        if (name) marker.title = [NSString stringWithUTF8String:name];
        if (url) marker.snippet = [NSString stringWithFormat:@"<a href=\"%s\">More Info</a>", url];
        marker.map = mapView_;
      }
      sqlite3_finalize(POIQueryStmt);
    } else
      NSLog(@"Failed to query database for POI data!");
  } else
    NSLog(@"Failed to open database!");

  [mapView addSubview:mapView_];
  mapView_.delegate = self;
  
  //dispatch_async(dispatch_get_main_queue(), ^{
  //    mapView_.myLocationEnabled = YES;
  //});
}

- (UIView*)mapView:(GMSMapView*)mapView
    markerInfoContents:(GMSMarker*)marker
{
  UIView *win = [[UIView alloc] initWithFrame: CGRectMake(0,0,0,0)];
  UILabel *title_label = [[UILabel alloc] initWithFrame: CGRectMake(0,0,0,0)];
  title_label.text = marker.title;
  [title_label sizeToFit];
  UIButton *moreinfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [moreinfo setTitle:@"More info" forState:UIControlStateNormal];
  [moreinfo sizeToFit];
  int numbuttons = 1;
  UIButton *share = 0;
  share = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  if (share) {
    numbuttons++;
    [share setTitle:@"Share" forState:UIControlStateNormal];
    [share sizeToFit];
  }
  int w = title_label.bounds.size.width;
  int h = title_label.bounds.size.height;
  int bw = moreinfo.frame.size.width + share.frame.size.width;
  if (share) bw = bw + share.frame.size.width;
  if (w<bw) w=bw;
  int bh = moreinfo.frame.size.height;
  if ((share) && (bh<share.frame.size.height)) bh=share.frame.size.height;
  if (h<bh) h=bh;
  title_label.frame = CGRectMake(0, 0, w, h);
  moreinfo.frame = CGRectMake(0, h, w/numbuttons, h);
  if (share)
    share.frame = CGRectMake(w/numbuttons, h, w/numbuttons, h);
  win.frame = CGRectMake(0, 0, w, 2*h);
  [win addSubview:title_label];
  [win addSubview:moreinfo];
  if (share)
    [win addSubview:share];
  return(win);
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
