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

@interface PUBLanguageTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *languageSelectionTableView;

@end

@implementation PUBLanguageTableViewController {
    NSArray *downloadedLanguageDocuments;
    NSArray *availableLanguageDocuments;
}

+ (UIViewController *)instantiateLanguageSelectionController {
    return [[UIStoryboard storyboardWithName:@"PUBLanguageSelection" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLanguageSelectionForDocument:(PUBDocument *)document {
    if (document.language.linkedTag.length > 0) {
        downloadedLanguageDocuments = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                          ascending:YES
                                                          predicate:[NSPredicate predicateWithFormat:@"state == %llu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]];
        
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
    
    cell.textLabel.text = document.language.localizedTitle;
    
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
        [self.delegate didSelectLanguageForDocument:document];
    }
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
