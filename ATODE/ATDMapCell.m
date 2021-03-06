//
//  ATDMapCell.m
//  ATODE
//
//  Created by himara2 on 2014/07/15.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDMapCell.h"
#import <MapKit/MapKit.h>
#import "MKMapView+ATDZoomLevel.h"
#import "ATDAnnotation.h"
#import "PlaceMemo.h"

@interface ATDMapCell ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapOverlayView;

@end


@implementation ATDMapCell

- (void)awakeFromNib
{    
    [self setUpViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpMapView {
    double lat = [_memo.latitude doubleValue];
    double lng = [_memo.longitude doubleValue];
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(lat, lng);
    [_mapView setCenterCoordinate:locationCoordinate zoomLevel:15 animated:YES];
    
    ATDAnnotation *annotation = [[ATDAnnotation alloc] initWithCoordinate:locationCoordinate
                                                                    title:_memo.placeInfo.name
                                                                 subtitle:_memo.title];
    [_mapView addAnnotation:annotation];
}

- (void)setUpViews {
    _mapView.layer.cornerRadius = 5.0f;
    _mapView.layer.masksToBounds = YES;
    _mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _mapView.layer.borderWidth = 0.5;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didTapOverlayView)];
    [_mapOverlayView addGestureRecognizer:tapGesture];
}


- (void)setMemo:(PlaceMemo *)memo {
    _memo = memo;
    [self setUpMapView];
}


- (void)didTapOverlayView {
    if ([_delegate respondsToSelector:@selector(didTapOverlayView)]) {
        [_delegate didTapOverlayView];
    }
}
@end
