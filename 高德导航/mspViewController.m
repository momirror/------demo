//
//  mspViewController.m
//  高德导航
//
//  Created by msp on 14-3-2.
//  Copyright (c) 2014年 msp. All rights reserved.
//

#import "mspViewController.h"
#import "NavigationViewController.h"

@interface mspViewController ()

@end

@implementation mspViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NavigationViewController *subViewController = [[NavigationViewController alloc] init];
    
    MAMapView * mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    AMapSearchAPI * search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    
    subViewController.mapView = mapView;
    subViewController.search  = search;
    
//    [self.navigationController pushViewController:(UIViewController*)subViewController animated:YES];
    [self.view addSubview:subViewController.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
