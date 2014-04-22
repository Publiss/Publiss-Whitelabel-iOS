//
//  PUBURLFactoryTest.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PublissCore/PUBURLFactory.h>
#import "PUBDocument.h"
#import "PUBConfig.h"

@interface PUBURLFactoryTest : XCTestCase

@end

@interface PUBURLFactory (test_methods)
+ (NSString *)createHashStringWithURL:(NSString *)urlString;
+ (NSString *)createHashStringWithURL:(NSString *)urlString parameters:(NSDictionary *)parameters;
+ (NSString *)createHashStringWithURL:(NSString *) urlString parameters:(NSDictionary *)parameters payload:(NSString *)payload;

+ (NSDictionary *)createSignedParametersWithURLString:(NSString *)urlString;
+ (NSDictionary *)createSignedParametersWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters;
+ (NSDictionary *)createSignedParametersWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters payload:(NSString *)payload;
@end

@implementation PUBURLFactoryTest

- (void)setUp
{
    [super setUp];
    NSMutableDictionary *currentSettings = [PUBConfig.sharedConfig valueForKey:@"currentSettings"];
    currentSettings[PUBConfigDefaultAppToken] = @"cf59bf5d-d528-483d-904c-b9f54688ed51";
    currentSettings[PUBConfigDefaultAppSecret] = @"b2a9975ccd5b50dd09cdf622427353ee";
    currentSettings[PUBConfigDefaultWebserviceBaseURL] = @"https://staging-backend.publiss.com";
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark -
#pragma mark currently used methods

- (void)testCreatePreviewImageURLStringForDocumentShouldSucceed {
    NSString *calculatedPreviewImageURLString = [PUBURLFactory createPreviewImageURLStringForDocument:12341 page:0];
    NSString *expectedURLString = @"https://staging-backend.publiss.com/v3/published_documents/12341/page/0.jpg?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&zz_checksum=d65872d3d970eb4bf1f1a38b862af6f562a19b0e346e634b5f1b6a05568f34a2a7c6f1e80599d2563edda7e9375f45f82d2778b7965d59af7fe382590aafa82e";
    XCTAssertEqualObjects(calculatedPreviewImageURLString, expectedURLString, @"Wrong URL created");
}

- (void)testCreateXDFURLForDocumentShouldSucceed {
    NSString *calculatedXDFURL =[PUBURLFactory createXDFURLForDocument:12341];
    NSString *expectedURLString = @"https://staging-backend.publiss.com/v3/published_documents/12341.xfdf?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&zz_checksum=0789419860897fbfb7215cd6b08fb4086016206ed0b59bbadf27dc7c341a20d3bb79ddbc7ece565a57fc2b0ba266fd65b722c2c7ba32fe6dc0e4890938754bf7";
    XCTAssertEqualObjects(calculatedXDFURL, expectedURLString, @"Wrong URL created");
}

- (void)testCreateImageURLStringForDocument {
    NSString *calculatedImageURLString = [PUBURLFactory createImageURLStringForDocument: 12341 page:0 parameters:@{@"keyA":@"valueA",@"keyB":@"valueB"}];
    NSString *expectedURLString = @"https://staging-backend.publiss.com/v3/published_documents/12341/page/0.jpg?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&keyA=valueA&keyB=valueB&zz_checksum=eadeab1f91403a1d799e3c693eae20342af80db0246a7a3c79f057927be7699326e3dd546b00260455663f1122f5221bc9a8a6eec07dd0121c493bfcca45a66a";
    XCTAssertEqualObjects(calculatedImageURLString, expectedURLString, @"Wrong URL created");
}

- (void)testCreateDownloadURLForDocument {
    NSURL *calculatedImageURL = [PUBURLFactory createDownloadURLForDocument:12341 page:0 iapSecret:@"secret" productId:@"productId"];
    NSURL *expectedURL = [NSURL.alloc initWithString:@"https://staging-backend.publiss.com/v3/published_documents/12341/page/0.pdf?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&iap_secret=secret&product_id=productId&zz_checksum=290179ad0f3e8c8b41625ac20a177199fb6814c6aac35fd47066a3ef4774d4681d4448f08813d96d3dec79c3b2d7f3b542c3c46efffbf62ca5ecc40959a6a90c"];
    XCTAssertEqualObjects(calculatedImageURL, expectedURL, @"Wrong URL created");
}

- (void)testCreatePublishedDocumentsPathShouldSucceed {
    NSString *calculatedImageURLString = [PUBURLFactory createPublishedDocumentsPath];
    NSString *expectedURLString = @"v3/published_documents";
    XCTAssertEqualObjects(calculatedImageURLString, expectedURLString, @"Wrong URL created");
}

- (void)testCreateSignedParametersShouldSucceed {
    NSDictionary *calculatedParameters = [PUBURLFactory createSignedParameters:@{@"keyA":@"valueA",@"keyB":@"valueB"} forPath:[PUBURLFactory createPublishedDocumentsPath]];
    NSDictionary *expectedParameters = @{@"app_token":@"cf59bf5d-d528-483d-904c-b9f54688ed51", @"keyA":@"valueA", @"keyB":@"valueB", @"zz_checksum":@"860b0a4c944e7704f947fcf735aeb792ce5c5dd14f418ea8d317b471d754ef3017c3c7d5cb3e7768dfceac92908b5eea98d77430f28930f6ee8a3d5f96720de8"};
    XCTAssertEqualObjects(calculatedParameters, expectedParameters, @"Wrong parameters created");
}

- (void)testCreateTrackingPathShouldSucceed {
    NSString *calculatedTrackingPath = [PUBURLFactory createTrackingPathForPayload:@{@"keyA":@"valueA"}];
    NSString *expectedTrackingPath = @"https://staging-backend.publiss.com/v3/tracking?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&zz_checksum=1086ff5db2ce4e8db214786a50c2cfc22bc8cf18d6e3f17eb5ba2319a1fb4a4b2b54bd594cb21f29a92a5b28ee6be7d949dc257495c5fc2cfb622b7fe5627622";
    XCTAssertEqualObjects(calculatedTrackingPath, expectedTrackingPath, @"Wrong URL created");
}

- (void)testCreateReceiptPathShouldSucceed {
    NSString *calculatedReceiptURLPath = [PUBURLFactory createReceiptPathForPayLoad:[NSDictionary dictionary]];
    NSString *expectedReceiptURLPath = @"https://staging-backend.publiss.com/v3/purchases?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&zz_checksum=8d02756c8381b6f810a7452e502f76d8e02a5fafbf5d75a2a59497b9160104b0fad778ce835ce77b3cbd9ea21c5e2d5599211bcaef2c6ccbfad8db84d6e2717d";
    XCTAssertEqualObjects(calculatedReceiptURLPath, expectedReceiptURLPath, @"Wrong URL created");
}

- (void)testCreateReceiptRestorePathShouldSucceed {
    NSString *calculatedReceiptURLPath = [PUBURLFactory createReceiptRestorePathForPayLoad:[NSDictionary dictionary]];
    NSString *expectedReceiptURLPath = @"https://staging-backend.publiss.com/v3/purchases/restore?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&zz_checksum=4f5326ba724e378c33d837c13f881a76f9a8f3b391e7f11f33ad6b35eff1ccfd2e4e7cd155aac47cbfd9ef9fac832afde43fa9178093ae190b235d6d01cae53f";
    XCTAssertEqualObjects(calculatedReceiptURLPath, expectedReceiptURLPath, @"Wrong URL created");
}

#pragma mark -
#pragma mark internal methods


- (void)testCreateHashStringWithPostBody {
    NSString *calculatedHashString = [PUBURLFactory createHashStringWithURL:@"pathForTest" parameters:@{@"a":@"valueA", @"b":@"valueB"} payload:@"payload"];
    NSString *expectedHashString = @"b2a9975ccd5b50dd09cdf622427353ee-https://staging-backend.publiss.com/pathForTest?a=valueA&app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&b=valueB-payload";
    XCTAssertEqualObjects(calculatedHashString, expectedHashString, @"Hash string created with wrong format");
}

- (void)testCreateHashStringWithParameters {
    NSString *calculatedHashString = [PUBURLFactory createHashStringWithURL:@"pathForTest" parameters:@{@"a":@"valueA", @"b":@"valueB"}];
    NSString *expectedHashString = @"b2a9975ccd5b50dd09cdf622427353ee-https://staging-backend.publiss.com/pathForTest?a=valueA&app_token=cf59bf5d-d528-483d-904c-b9f54688ed51&b=valueB";
    XCTAssertEqualObjects(calculatedHashString, expectedHashString, @"Hash string created with wrong format");
}

- (void)testCreateHashStringWithoutParameters {
    NSString *calculatedHashString = [PUBURLFactory createHashStringWithURL:@"pathForTest"];
    NSString *expectedHashString = @"b2a9975ccd5b50dd09cdf622427353ee-https://staging-backend.publiss.com/pathForTest?app_token=cf59bf5d-d528-483d-904c-b9f54688ed51";
    XCTAssertEqualObjects(calculatedHashString, expectedHashString, @"Hash string created with wrong format");
}

- (void)testCreateSignedParametersWithoutRequestParameters {
    NSDictionary *signedParameters = [PUBURLFactory createSignedParametersWithURLString:@"https://staging-backend.publiss.com"];
    NSDictionary *expectedParameters = @{@"app_token":@"cf59bf5d-d528-483d-904c-b9f54688ed51", @"zz_checksum":@"1eb9640b487d74357d61af4633c3f96edd11b984bfddf19264ba5a44435336862c96cc4a005d89bc64350b8374b8fa36cb82150c845ed390e740766f137b44db"};
    XCTAssertEqualObjects(signedParameters, expectedParameters, @"Failed creating signed parameters");
}

- (void)testCreateSignedParametersWithRequestParameters {
    NSDictionary *signedParameters = [PUBURLFactory createSignedParametersWithURLString:@"https://staging-backend.publiss.com" parameters:@{@"a": @"valueA", @"b":@"valueB"} payload:nil];
    NSDictionary *expectedParameters = @{@"a": @"valueA",@"app_token":@"cf59bf5d-d528-483d-904c-b9f54688ed51", @"b":@"valueB",  @"zz_checksum":@"7d9ee9b477bb8bc8509eefd05ebcde73beb7b8c3eb5b6b16d8bfec9262e8f5fde62671361c93e5043b2cc503e6fee2b809f75486ae7caf865da2fa51094cd880"};
    XCTAssertEqualObjects(signedParameters, expectedParameters, @"Failed creating signed parameters");
}

- (void)testCreateSignedParametersWithPayload {
    NSString *payload = @"payload";
    NSDictionary *signedParameters = [PUBURLFactory createSignedParametersWithURLString:@"https://staging-backend.publiss.com" parameters:@{@"a": @"valueA", @"b":@"valueB"} payload:payload];
    NSDictionary *expectedParameters = @{@"a": @"valueA",@"app_token":@"cf59bf5d-d528-483d-904c-b9f54688ed51", @"b":@"valueB",  @"zz_checksum":@"ebae2c3cc59ed0ad783e9a4e109c392e4cb77bc4ded1db8dba94dc97a5405f23ec309bfac6510314a5fef2e2acceb98c78ba2723089a2e91a21545f6d52ea8a4"};
    XCTAssertEqualObjects(signedParameters, expectedParameters, @"Failed creating signed parameters");
}


@end
