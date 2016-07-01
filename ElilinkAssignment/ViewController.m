//
//  ViewController.m
//  ElilinkAssignment
//
//  Created by Dmitry Smolyakov on 6/30/16.
//  Copyright © 2016 Dmitry Smolyakov. All rights reserved.
//

#import "ViewController.h"

//frameworks
#import <MagicalRecord/MagicalRecord.h>
#import <OWMWeatherAPI.h>

//models
#import "DSCity.h"

typedef NS_ENUM(NSInteger, ViewControllerDescriptionViewStatus) {
    ViewControllerDescriptionViewStatusDefault,
    ViewControllerDescriptionViewStatusZoomed
};

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *zoomedStateConst;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *defaultStateConst;

@property (weak, nonatomic) IBOutlet UILabel *cityNameCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) ViewControllerDescriptionViewStatus status;
@property (strong, nonatomic) NSArray <DSCity *> *cities;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) UIInterfaceOrientation currentOrientation;

@property (strong, nonatomic) OWMWeatherAPI *owmWeatherAPI;

@end

static const NSInteger weatherUpdateInterval = 60 * 60; //one hour

@implementation ViewController

#pragma mark - Setters

- (void)setStatus:(ViewControllerDescriptionViewStatus)status {
    _status = status;
    [self updateConstraintToState];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupWeatherAPI];
    [self updateDescriptionViewWithIndexPath:self.selectedIndexPath];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[UIApplication sharedApplication] statusBarOrientation] != self.currentOrientation) {
        self.currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self updateConstraintToState];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self selecDefaultIndexPath];
}

#pragma mark - Setup

- (void)loadData {
    self.cities = [DSCity MR_findAllSortedBy:@"name" ascending:YES];
}

- (void)setupWeatherAPI {
    
    self.owmWeatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"eba47effea88b18d5b67eae531209447"];
    [self.owmWeatherAPI setTemperatureFormat:kOWMTempCelcius];
}

- (void)selecDefaultIndexPath {
    if (!self.selectedIndexPath) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [self rowDidSelectedAtIndexPath:indexPath];
    }
}

#pragma mark - Constraints

- (void)updateConstraintToState {
    
    switch (self.status) {
        case ViewControllerDescriptionViewStatusDefault:
        for (NSLayoutConstraint *constraints in self.zoomedStateConst) {
            constraints.active = NO;
        }
        for (NSLayoutConstraint *constraints in self.defaultStateConst) {
            constraints.active = YES;
        }
        break;
        case ViewControllerDescriptionViewStatusZoomed:
        for (NSLayoutConstraint *constraints in self.defaultStateConst) {
            constraints.active = NO;
        }
        for (NSLayoutConstraint *constraints in self.zoomedStateConst) {
            constraints.active = YES;
        }
        break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    DSCity *city = self.cities[indexPath.row];
    cell.textLabel.text = city.name;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.detailTextLabel.text = city.code;
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self rowDidSelectedAtIndexPath:indexPath];
}

#pragma mark - UI updates

- (void)updateDescriptionViewWithIndexPath:(NSIndexPath *)indexPath {
    
    DSCity *city = self.cities[indexPath.row];
    self.cityNameCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", city.name, city.code];
    self.descriptionTextView.text = city.cityDescription;
    if (city.lastUpdatedWeatherDate) {
        NSString *stringWeather = [NSString stringWithFormat:@"%0.1f", [city.weather floatValue]];
        self.weatherLabel.text = [stringWeather stringByAppendingString:@"ºC"];
    }
    else {
        self.weatherLabel.text = @"No info";
    }
}

#pragma mark - WeatherSync

- (void)syncWeatherWithServer:(DSCity *)city {
    
    if ([self weatherWasUpdatedEarlierThanAnHourAgo:(DSCity *)city]) {
        NSString *cityName = [city.name stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self.owmWeatherAPI currentWeatherByCityName:cityName withCallback:^(NSError *error, NSDictionary *result) {
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                DSCity *cityInLocalContext = [DSCity MR_findFirstByAttribute:@"name" withValue:city.name inContext:localContext];
                [cityInLocalContext updateWeatherWithDictionary:result];
            } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateDescriptionViewWithIndexPath:self.selectedIndexPath];
                });
            }];
        }];
    }
}

- (BOOL)weatherWasUpdatedEarlierThanAnHourAgo:(DSCity *)city {
    return [[NSDate date] timeIntervalSince1970] - [city.lastUpdatedWeatherDate timeIntervalSince1970] > weatherUpdateInterval ? YES : NO;
}

#pragma mark - Actions

- (IBAction)actionTap:(UITapGestureRecognizer *)sender {
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.status = self.status == ViewControllerDescriptionViewStatusDefault ? ViewControllerDescriptionViewStatusZoomed : ViewControllerDescriptionViewStatusDefault;
        [self.view layoutIfNeeded];
    }];
}

- (void)rowDidSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    [self updateDescriptionViewWithIndexPath:indexPath];
    DSCity *city = self.cities[indexPath.row];
    [self syncWeatherWithServer:(DSCity *)city];
}

@end
