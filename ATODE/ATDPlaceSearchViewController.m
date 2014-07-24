//
//  ATDPlaceSearchViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/06.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDPlaceSearchViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "ATD4sqPlace.h"


static NSString * const kApiClientID = @"UXFP35M0BBM3BSQS0IEDLDHQECN4PIP5IYE14CD4MBR1VPS2";
static NSString * const kApiClientSecret = @"FWEEVYATFIJXWUOLHBYKDUUVLKEDU2L0DHYJXU5ZA14YCXY2";

@interface ATDPlaceSearchViewController ()
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) NSArray *filterdPlaces;



@end



@implementation ATDPlaceSearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}


- (void)reloadData {
#if (TARGET_IPHONE_SIMULATOR)
    NSString *ll = @"35.661913, 139.700943";    // Tokyo tower
#else
    NSString *ll = [NSString stringWithFormat:@"%f,%f",
                    _coordinate.latitude,
                    _coordinate.longitude];
#endif
    
    NSDictionary *params = @{@"client_id":kApiClientID,
                             @"client_secret":kApiClientSecret,
                             @"v":@"20140707",
                             @"ll":ll};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://api.foursquare.com/v2/venues/search"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray *venues = responseObject[@"response"][@"venues"];
             
             NSMutableArray *mutArray = [NSMutableArray array];
             [venues enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                 ATD4sqPlace *place = [[ATD4sqPlace alloc] initWithDictionary:dict];
                 [mutArray addObject:place];
             }];
             
             self.places = mutArray;
             [_tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error:[%@]", error);
         }];

}


- (void)searchPlaceWithFourSquare:(NSString *)query {
    NSLog(@"searchString[%@]", query);
    
    NSString *ll = [NSString stringWithFormat:@"%f,%f",
                    _coordinate.latitude,
                    _coordinate.longitude];
    
    NSDictionary *params = @{@"client_id":kApiClientID,
                             @"client_secret":kApiClientSecret,
                             @"query":query,
                             @"v":@"20140707",
                             @"ll":ll};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://api.foursquare.com/v2/venues/search"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray *venues = responseObject[@"response"][@"venues"];
             
             NSMutableArray *mutArray = [NSMutableArray array];
             [venues enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                 ATD4sqPlace *place = [[ATD4sqPlace alloc] initWithDictionary:dict];
                 [mutArray addObject:place];
             }];
             
             self.filterdPlaces = mutArray;
             [_tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error:[%@]", error);
         }];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filterdPlaces count];
    }
    else {
        return [_places count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"Cell"];
    
    ATD4sqPlace *place;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = _filterdPlaces[indexPath.row];
    }
    else {
        place = _places[indexPath.row];
    }
    
    cell.textLabel.text = place.name;
    if (place.address) {
        cell.detailTextLabel.text = place.address;
    }
    else {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ATD4sqPlace *place = _places[indexPath.row];
    if ([_delegate respondsToSelector:@selector(didSelectPlace:)]) {
        [_delegate didSelectPlace:place];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSLog(@"delegate not found");
    }
}


- (BOOL)searchDisplayController:controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self searchPlaceWithFourSquare:searchString];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchPlaceWithFourSquare:searchBar.text];
}



@end
