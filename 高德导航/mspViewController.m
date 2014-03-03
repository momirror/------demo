//
//  mspViewController.m
//  高德导航
//
//  Created by msp on 14-3-2.
//  Copyright (c) 2014年 msp. All rights reserved.
//

#import "mspViewController.h"
#import "NavigationViewController.h"
#import "RouteDetailViewController.h"
#import "CommonUtility.h"
#import "LineDashPolyline.h"
//
//
///*步行导航类*/
//
//const NSString *NavigationViewControllerStartTitle       = @"起点";
//const NSString *NavigationViewControllerDestinationTitle = @"终点";



@interface mspViewController ()
@property (nonatomic) AMapSearchType searchType;
@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;

@property (nonatomic, strong) UIBarButtonItem *previousItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

@end



@implementation mspViewController

@synthesize searchType  = _searchType;
@synthesize route       = _route;

@synthesize currentCourse = _currentCourse;
@synthesize totalCourse   = _totalCourse;

@synthesize previousItem = _previousItem;
@synthesize nextItem     = _nextItem;

@synthesize startCoordinate         = _startCoordinate;
@synthesize destinationCoordinate   = _destinationCoordinate;

- (void)viewDidLoad
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    
    [super viewDidLoad];
	
    
    self.startCoordinate        = CLLocationCoordinate2DMake(22.5700208926, 113.9480707440);
    self.destinationCoordinate  = CLLocationCoordinate2DMake(22.5430615002, 113.9493257440);
//    NavigationViewController *subViewController = [[NavigationViewController alloc] init];
//    subViewController.hidesBottomBarWhenPushed = YES;
//    
//    
//    
//     mapView.showsUserLocation = YES;
////    mapView.headingFilter = kCLHeadingFilterNone;
//     [mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES];  //旋转
    
    AMapSearchAPI * search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.delegate=self;
    
    self.search =  search;
    self.search.delegate = self;
    
    self.searchType = AMapSearchType_NaviWalking;
    self.route = nil;
    self.totalCourse   = 0;
    self.currentCourse = 0;
    [self clear];
    [self searchNaviWalk];
    
    [self addDefaultAnnotations];
   
    
//    [self.navigationController pushViewController:(UIViewController*)subViewController animated:YES];
//    [self.view addSubview:subViewController.view];
    
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse
{
    NSArray *polylines = nil;
    
    /* 公交导航. */
    if (self.searchType == AMapSearchType_NaviBus)
    {
        polylines = [CommonUtility polylinesForTransit:self.route.transits[self.currentCourse]];
    }
    /* 步行，驾车导航. */
    else
    {
        polylines = [CommonUtility polylinesForPath:self.route.paths[self.currentCourse]];
    }
    
    [self.mapView addOverlays:polylines];
    
    /* 缩放地图使其适应polylines的展示. */
    self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polylines];
}

/* 清空地图上的overlay. */
- (void)clear
{
    [self.mapView removeOverlays:self.mapView.overlays];
}


#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth   = 4;
        overlayView.strokeColor = [UIColor magentaColor];
        overlayView.lineDashPattern = @[@5, @10];
        
        return overlayView;
    }
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        overlayView.lineWidth   = 8;
        overlayView.strokeColor = [UIColor magentaColor];
        
        return overlayView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:navigationCellIdentifier];
            
            poiAnnotationView.canShowCallout = YES;
        }
        
        /* 起点. */
        if ([[annotation title] isEqualToString:@"起点"])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:@"终点"])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
        }
        else if([[annotation title] isEqualToString:@"当前位置"])
        {
            NSLog(@"当前位置");
            poiAnnotationView.image = [UIImage imageNamed:@"avatar_1"];
            _myAnnotationView = [poiAnnotationView retain];

        }
        
        if(_myAnnotationView != nil)//确保表示当前位置的图标可以显示出来
        {
            [[_myAnnotationView superview] bringSubviewToFront:_myAnnotationView];
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate

/* 导航搜索回调. */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request
                      response:(AMapNavigationSearchResponse *)response
{
    
    NSLog(@"导航搜索回调");
    
    if (self.searchType != request.searchType)
    {
        return;
    }
    
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
//    [self updateTotal];
    self.currentCourse = 0;
    
//    [self updateCourseUI];
//    [self updateDetailUI];
    
    [self presentCurrentCourse];
}

/* 步行导航搜索. */
- (void)searchNaviWalk
{
    AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
    navi.searchType       = AMapSearchType_NaviWalking;
    navi.requireExtension = YES;
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];

    //     navi.origin = [AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude
//longitude:self.mapView.centerCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapNavigationSearch:navi];
}


- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = @"起点";
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = @"终点";
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    NSLog(@"myAnnotation.coordinate->%f,%f",destinationAnnotation.coordinate.latitude,destinationAnnotation.coordinate.longitude);
    
    MAPointAnnotation *myAnnotation = [[MAPointAnnotation alloc] init];
//    myAnnotation.coordinate = self.mapView.centerCoordinate;
    myAnnotation.coordinate = self.destinationCoordinate;;
    myAnnotation.title      = @"当前位置";
    myAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude];

    NSLog(@"myAnnotation.coordinate->%f,%f",myAnnotation.coordinate.latitude,myAnnotation.coordinate.longitude);
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
     [self.mapView addAnnotation:myAnnotation];
}

#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.startCoordinate        = CLLocationCoordinate2DMake(22.5700208926, 113.9480707440);
        self.destinationCoordinate  = CLLocationCoordinate2DMake(22.5430615002, 113.9493257440);
    }
    
    return self;
}




@end
