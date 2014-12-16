//
//  PUBUserLoginViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 05.12.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUserLoginViewController.h"
#import "PUBUserLoginFieldTableViewCell.h"

@interface PUBUserLoginViewController ()

@property (nonatomic, strong) NSArray *loginFields;

@end

@implementation PUBUserLoginViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    self.loginFields = @[
                         @{@"title": @"Email", @"type": @"PUBUserLoginTextFieldCell", @"parameter_name": @"email"},
                         @{@"title": @"Name", @"type": @"PUBUserLoginTextFieldCell", @"parameter_name": @"name"},
                         @{@"title": @"Password", @"type": @"PUBUserLoginPasswordFieldCell", @"parameter_name": @"password"}
                         ];
}

+ (PUBUserLoginViewController *)userLoginViewController {
    return [[UIStoryboard storyboardWithName:@"PUBUserLogin" bundle:nil] instantiateInitialViewController];
}

#pragma mark - UI actions

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loginFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellConfiguration = self.loginFields[indexPath.row];
    NSString *CellIdentifier = (NSString *)cellConfiguration[@"type"];
    
    PUBUserLoginFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setupFieldWithTitle:cellConfiguration[@"title"] andParameterName:cellConfiguration[@"parameter_name"]];

    return cell;
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
