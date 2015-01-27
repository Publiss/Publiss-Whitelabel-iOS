//
//  PUBUserLoginViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 05.12.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUserLoginViewController.h"
#import "PUBUserLoginFieldTableViewCell.h"
#import "UIColor+PUBDesign.h"
#import "PUBCommunication.h"
#import "PUBAuthentication.h"
#import "UIImage+ImageEffects.h"
#import "PUBConfig.h"

@interface PUBUserLoginViewController () {
    CGFloat _initialTopLogoSpacing;
    CGFloat _initialBottomTableSpacing;
}

@property (nonatomic, strong) NSArray *loginFieldsConfiguration;
@property (nonatomic, strong) NSMutableDictionary *loginFields;
@property (nonatomic, strong) id<PUBUserLoginDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *submitLoginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLogoSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@end

@implementation PUBUserLoginViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginFields = [[NSMutableDictionary alloc] init];
    self.loginFieldsConfiguration = PUBAuthentication.sharedInstance.loginFields;
    
    self.submitLoginButton.backgroundColor = [UIColor publissPrimaryColor];
    _initialTopLogoSpacing = self.topLogoSpacingConstraint.constant;
    _initialBottomTableSpacing = self.bottomTableSpacingConstraint.constant;
    
    [self observeKeyboard];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return PUBConfig.sharedConfig.statusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateImage];
}

- (void)updateImage {
    UIGraphicsBeginImageContext(self.presentingViewController.view.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.presentingViewController.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (PUBConfig.sharedConfig.blurEffectStyle == PUBBlurEffectStyleLight) {
        [self.background setImage:[img applyLightEffect]];
    }
    else {
        [self.background setImage:[img applyDarkEffect]];
    }
}

- (void)didRotate:(NSNotification *)notification {
    [self updateImage];
}

+ (PUBUserLoginViewController *)userLoginViewController {
    return [[UIStoryboard storyboardWithName:@"PUBUserLogin" bundle:nil] instantiateInitialViewController];
}

+ (PUBUserLoginViewController *)userLoginViewControllerWithDelegate:(id<PUBUserLoginDelegate>)delegate {
    PUBUserLoginViewController *controller = [self userLoginViewController];
    controller.delegate = delegate;
    return controller;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI actions

- (IBAction)closeButtonPressed:(id)sender {
    [self close];
}

- (IBAction)submitButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    BOOL validationOkay = YES;
    for (NSString* key in self.loginFields) {
        PUBUserLoginFieldTableViewCell *cell = (PUBUserLoginFieldTableViewCell *)[self.loginFields objectForKey:key];
        [parameters setObject:[cell getParameterValue] forKey:[cell getParameterName]];
    }
    
    if (PUBAuthentication.sharedInstance.additionalLoginParameters) {
        [parameters addEntriesFromDictionary:PUBAuthentication.sharedInstance.additionalLoginParameters];
    }
    
    if ([self.delegate respondsToSelector:@selector(pubUserLoginWillLoginWithCredentials:)]) {
        validationOkay = [self.delegate pubUserLoginWillLoginWithCredentials:parameters];
    }

    if (validationOkay) {
        [self performLoginRequestWithParameters:parameters];
    }
}

- (void)performLoginRequestWithParameters:(NSDictionary *)parameters {
    [PUBCommunication.sharedInstance sendLogin:parameters
                                    completion:^(id responseObject){
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            NSDictionary *response = (NSDictionary *)responseObject;
                                            if ([[response allKeys] containsObject:@"error"]) {
                                                if ([self.delegate respondsToSelector:@selector(pubUserLoginFailedWithError:)]) {
                                                    [self.delegate pubUserLoginFailedWithError:[response objectForKey:@"error"]];
                                                }
                                            }
                                            else {
                                                if ([self.delegate respondsToSelector:@selector(pubUserLoginSucceededWithToken:andResponse:andParameters:)]) {
                                                    [self.delegate pubUserLoginSucceededWithToken:[response objectForKey:@"access_token"] andResponse:response andParameters:parameters];
                                                }
                                            }
                                        }
                                    }
                                         error:^(NSError *error){
                                             if ([self.delegate respondsToSelector:@selector(pubUserLoginFailedWithError:)]) {
                                                 [self.delegate pubUserLoginFailedWithError:[error localizedDescription]];
                                             }
                                         }];
}

#pragma mark - Layout

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrame = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameRect = [keyboardFrame CGRectValue];

    self.topLogoSpacingConstraint.constant = -85.0f;
    self.bottomTableSpacingConstraint.constant = keyboardFrameRect.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.topLogoSpacingConstraint.constant = _initialTopLogoSpacing;
    self.bottomTableSpacingConstraint.constant = _initialBottomTableSpacing;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loginFieldsConfiguration.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellConfiguration = self.loginFieldsConfiguration[indexPath.row];
    NSString *CellIdentifier = (NSString *)cellConfiguration[@"class"];
    
    PUBUserLoginFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setupFieldWithTitle:cellConfiguration[@"title"] andParameterName:cellConfiguration[@"parameter_name"]];
    
    if (![[self.loginFields allKeys] containsObject:cellConfiguration[@"parameter_name"]]) {
        [self.loginFields setObject:cell forKey:cellConfiguration[@"parameter_name"]];
    }

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
