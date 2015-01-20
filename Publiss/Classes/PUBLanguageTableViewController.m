//
//  PUBLanguageTableViewController.m
//  Publiss
//
//  Created by Lukas Korl on 14/01/15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBLanguageTableViewController.h"
#import "PUBDocument+Helper.h"
#import "PUBLanguage+Helper.h"
#import "UIColor+PUBDesign.h"
#import "PUBConfig.h"
#import "PUBLanguageSelectionCell.h"
#import "PUBConstants.h"

@interface PUBLanguageTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *languageSelectionTableView;
@property (strong, nonatomic) NSArray *downloadedLanguageDocuments;
@property (strong, nonatomic) NSArray *availableLanguageDocuments;

@end

@implementation PUBLanguageTableViewController

+ (PUBLanguageTableViewController *)instantiateLanguageSelectionController {
    return [[UIStoryboard storyboardWithName:@"PUBLanguageSelection" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.downloadedLanguageDocuments) {
        self.downloadedLanguageDocuments = @[];
    }
    if (!self.availableLanguageDocuments) {
        self.availableLanguageDocuments = @[];
    }
    
    self.title = PUBLocalize(@"Languages");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (PUBIsiPad()) {
        self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.recognizer.numberOfTapsRequired = 1;
        self.recognizer.cancelsTouchesInView = NO;
        [self.view.window addGestureRecognizer:self.recognizer];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (PUBIsiPad()) {
        // this sizes are for ipad only
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            if (PUBIsiOS8OrHigher()) {
                ((UINavigationController *)self.parentViewController).view.frame = CGRectMake(242, 74, 540, 620);
            } else {
                ((UINavigationController *)self.parentViewController).view.frame = CGRectMake(74, 242, 620, 540);
            }
            
        } else {
            ((UINavigationController *)self.parentViewController).view.frame = CGRectMake(114, 202, 540, 620);
        }
    }
}

- (void)setupLanguageSelectionForDocument:(PUBDocument *)document {
    self.downloadedLanguageDocuments = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                           ascending:YES
                                                           predicate:[NSPredicate predicateWithFormat:@"state == %lu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]];
    
    self.availableLanguageDocuments = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                          ascending:YES
                                                          predicate:[NSPredicate predicateWithFormat:@"state != %lu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.downloadedLanguageDocuments.count == 0 || self.availableLanguageDocuments.count == 0) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.downloadedLanguageDocuments.count > 0) {
        return [NSString stringWithFormat:@"%@:", PUBLocalize(@"Already downloaded")];
    }
    
    if (self.availableLanguageDocuments.count == 1) {
        return [NSString stringWithFormat:@"%@:", PUBLocalize(@"Alternative language")];
    }
    
    return [NSString stringWithFormat:@"%lu %@:", (unsigned long)self.availableLanguageDocuments.count, PUBLocalize(@"Languages")];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.downloadedLanguageDocuments.count > 0) {
        return self.downloadedLanguageDocuments.count;
    }
    return self.availableLanguageDocuments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DocumentLanguageCell";
    PUBLanguageSelectionCell *languageCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    PUBDocument *document;
    if (indexPath.section == 0 && self.downloadedLanguageDocuments.count > 0) {
        document = (PUBDocument *)[self.downloadedLanguageDocuments objectAtIndex:indexPath.row];
    }
    else {
        document = (PUBDocument *)[self.availableLanguageDocuments objectAtIndex:indexPath.row];
    }
    
    [languageCell setupCellForDocument:document];
    
    return languageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = nil;
    if (indexPath.section == 0 && self.downloadedLanguageDocuments.count > 0) {
        document = [self.downloadedLanguageDocuments objectAtIndex:indexPath.row];
    }
    else {
        document = [self.availableLanguageDocuments objectAtIndex:indexPath.row];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLanguageForDocument:)]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.delegate didSelectLanguageForDocument:document];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && self.downloadedLanguageDocuments.count > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = [self.downloadedLanguageDocuments objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveLanguageForDocument:)]) {
        [self.delegate didRemoveLanguageForDocument:document];
    }
    
    [self setupLanguageSelectionForDocument:document];
    [tableView reloadData];
}

#pragma mark - Dismiss ViewController

// http://stackoverflow.com/questions/2623417/iphone-sdk-dismissing-modal-viewcontrollers-on-ipad-by-clicking-outside-of-it
// FOR iOS8 and iOS7.1: http://stackoverflow.com/a/25844208
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIView *rootView = self.view.window.rootViewController.view;
        CGPoint location = [sender locationInView:rootView];
        UIView *navigationControllerView = ((UINavigationController *)self.parentViewController).view;
        if (![navigationControllerView pointInside:[navigationControllerView convertPoint:location fromView:rootView] withEvent:nil]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.view.window removeGestureRecognizer:sender];
            }];
        }
    }
}

@end
