//
//  MapViewController.h
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 10/20/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ConfigModel.h"

@interface MapViewController : UIViewController
                                 <CLLocationManagerDelegate,
                                  GMSMapViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *mapView;
@property ConfigModel *configModel;

@end

