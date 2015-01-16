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

@end
