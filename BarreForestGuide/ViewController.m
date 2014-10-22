//
//  ViewController.m
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 10/20/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController ()
@end

@implementation ViewController {
  GMSMapView        *mapView_;
  CLLocationManager *locationManager_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  if (locationManager_ == nil)
    locationManager_ = [[CLLocationManager alloc] init];
  locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
  locationManager_.delegate = self;
  [locationManager_ startUpdatingLocation];

  GMSCameraPosition *camera = [ GMSCameraPosition cameraWithLatitude:44.150004 longitude:-72.469339 zoom:15];
  mapView_ =  [GMSMapView mapWithFrame:CGRectZero camera:camera];
  //mapView_.myLocationEnabled = YES;
  
  //[mapView_ addObserver:self
  //           forKeyPath:@"myLocation"
  //              options:NSKeyValueObservingOptionNew
  //              context:NULL];
  
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
    GMSCameraUpdate *locUpdate = [GMSCameraUpdate setTarget:location.coordinate zoom:20];
    [mapView_ animateWithCameraUpdate:locUpdate];
  }
  NSLog(@"Got a new location update");
}

- (void)locationManager:(CLLocationManager*)manager
       didFailWithError:(NSError*)error
{
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  //[mapView_ removeObserver:self
  //              forKeyPath:@"myLocation"
  //                 context:NULL];
}

@end
