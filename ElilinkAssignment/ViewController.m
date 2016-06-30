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

//models
#import "DSCity.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityNameStandartHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityNameZoomedHeightConst;

@property (assign, nonatomic) NSInteger status;

@property (weak, nonatomic) IBOutlet UILabel *cityNameCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nullable, weak, nonatomic, readonly) NSArray <DSCity *> *cities;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (IBAction)actionTap:(UITapGestureRecognizer *)sender;

@end

typedef NS_ENUM(NSInteger, ViewControllerDescriptionViewStatus) {
    ViewControllerDescriptionViewStatusDefault,
    ViewControllerDescriptionViewStatusZoomed
};

static const CGFloat descriptionViewHeightMultiplierStateDefault = 0.33f;
static const CGFloat descriptionViewHeightMultiplierStateZoomed = 0.6f;

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [DSCity MR_requestAllSortedBy:@"name" ascending:YES];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)performFetch {
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSArray <DSCity *> *)cities {
    return self.fetchedResultsController.fetchedObjects;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    DSCity *city = self.cities[indexPath.row];
    cell.textLabel.text = city.name;
    cell.detailTextLabel.text = city.code;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedIndexPath != indexPath) {
        self.selectedIndexPath = indexPath;
        [self updateDescriptionViewWithIndexPath:indexPath];
    }
}


#pragma mark - UI updates

- (void)setupConstraints {
    self.descriptionViewHeightConst.constant = CGRectGetHeight(self.view.bounds) * descriptionViewHeightMultiplierStateDefault;
    self.status = ViewControllerDescriptionViewStatusDefault;
}

- (void)updateDescriptionViewWithIndexPath:(NSIndexPath *)indexPath {
    
    DSCity *city = self.cities[indexPath.row];
    self.cityNameCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", city.name, city.code];
    self.weatherLabel.text = city.weather ? city.weather : @"No data";
    self.descriptionTextView.text = city.cityDescription;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - Animations

- (void)animateConstraintsWithMultiplier:(CGFloat)multiplier {
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.descriptionViewHeightConst.constant = CGRectGetHeight(self.view.bounds) * multiplier;
        if (self.cityNameStandartHeightConst.active) {
            self.cityNameStandartHeightConst.active = NO;
            self.cityNameZoomedHeightConst.active = YES;
        }
        else {
            self.cityNameZoomedHeightConst.active = NO;
            self.cityNameStandartHeightConst.active = YES;
        }
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)actionTap:(UITapGestureRecognizer *)sender {
    
    [self.view layoutIfNeeded];
    
    if (self.status == ViewControllerDescriptionViewStatusDefault) {
        self.status = ViewControllerDescriptionViewStatusZoomed;
        [self animateConstraintsWithMultiplier:descriptionViewHeightMultiplierStateZoomed];
    }
    else {
        self.status = ViewControllerDescriptionViewStatusDefault;
        [self animateConstraintsWithMultiplier:descriptionViewHeightMultiplierStateDefault];
    }
}

@end
