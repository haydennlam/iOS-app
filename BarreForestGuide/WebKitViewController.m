//
//  WebKitViewController.m
//  BarreForestGuide
//
//  Created by Craig B. Agricola on 11/21/14.
//  Copyright (c) 2014 Town of Barre. All rights reserved.
//

#import "WebKitViewController.h"

@interface WebKitViewController ()
@end

@implementation WebKitViewController {}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.url) {
    [self.webKit loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
  }
}

@end

/* vim: set ai si sw=2 ts=80 ru: */
