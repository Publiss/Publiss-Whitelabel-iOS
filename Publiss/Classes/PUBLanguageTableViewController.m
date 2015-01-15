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

@end

@implementation PUBLanguageTableViewController {
    NSMutableArray *downloadedLanguageDocuments;
    NSArray *availableLanguageDocuments;
}

+ (UIViewController *)instantiateLanguageSelectionController {
    return [[UIStoryboard storyboardWithName:@"PUBLanguageSelection" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = PUBLocalize(@"Languages");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLanguageSelectionForDocument:(PUBDocument *)document {
    if (document.language.linkedTag.length > 0) {
        downloadedLanguageDocuments = [NSMutableArray arrayWithArray:[PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                          ascending:YES
                                                          predicate:[NSPredicate predicateWithFormat:@"state == %llu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]]];
        
        availableLanguageDocuments = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                         ascending:YES
                                                         predicate:[NSPredicate predicateWithFormat:@"state != %llu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (downloadedLanguageDocuments.count == 0 || availableLanguageDocuments.count == 0) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && downloadedLanguageDocuments.count > 0) {
        return [NSString stringWithFormat:@"%@:", PUBLocalize(@"Already downloaded")];
    }
    
    if (availableLanguageDocuments.count == 1) {
        return [NSString stringWithFormat:@"%@:", PUBLocalize(@"Alternative language")];
    }
    
    return [NSString stringWithFormat:@"%lu %@:", (unsigned long)availableLanguageDocuments.count, PUBLocalize(@"Languages")];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && downloadedLanguageDocuments.count > 0) {
        return downloadedLanguageDocuments.count;
    }
    return availableLanguageDocuments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DocumentLanguageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    PUBDocument *document;
    if (indexPath.section == 0 && downloadedLanguageDocuments.count > 0) {
        document = (PUBDocument *)[downloadedLanguageDocuments objectAtIndex:indexPath.row];
    }
    else {
        document = (PUBDocument *)[availableLanguageDocuments objectAtIndex:indexPath.row];
    }
    
    if ([cell isKindOfClass:[PUBLanguageSelectionCell class]]) {
        PUBLanguageSelectionCell *languageCell = (PUBLanguageSelectionCell *)cell;
        [languageCell setupCellForDocument:document];
    }
    
    NSMutableAttributedString *languageTitle = [[NSMutableAttributedString alloc] initWithString:document.language.localizedTitle];
    if (PUBConfig.sharedConfig.preferredLanguage && [document.language.languageTag isEqualToString:PUBConfig.sharedConfig.preferredLanguage]) {
        NSMutableAttributedString *postfix = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@" (%@)", PUBLocalize(@"Default")]];
        [postfix addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,postfix.length)];
        [languageTitle appendAttributedString:postfix];
    }
    [cell.textLabel setAttributedText:languageTitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = nil;
    if (indexPath.section == 0 && downloadedLanguageDocuments.count > 0) {
        document = [downloadedLanguageDocuments objectAtIndex:indexPath.row];
    }
    else {
        document = [availableLanguageDocuments objectAtIndex:indexPath.row];
    }
    
    if (self.delegate) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.delegate didSelectLanguageForDocument:document];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && downloadedLanguageDocuments.count > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = [downloadedLanguageDocuments objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate didRemoveLanguageForDocument:document];
    }
    
    [self setupLanguageSelectionForDocument:document];
    [tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
