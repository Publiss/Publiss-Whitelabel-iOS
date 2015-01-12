//
//  PUBDocumentHelperTests.m
//  Publiss
//
//  Created by Denis Andrasec on 12.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PUBDocument+Helper.h"
#import "PUBLanguage+Helper.h"

@interface PUBDocumentHelperTests : XCTestCase

@property (nonatomic, strong) PUBDocument *d1;
@property (nonatomic, strong) PUBDocument *d2;
@property (nonatomic, strong) PUBDocument *d3;
@property (nonatomic, strong) PUBDocument *d4;

@property (nonatomic, strong) NSDictionary *language_a_en;
@property (nonatomic, strong) NSDictionary *language_a_de;
@property (nonatomic, strong) NSDictionary *language_b_en;

@end

@implementation PUBDocumentHelperTests

- (void)setUp {
    [super setUp];
    
    self.d1 = [PUBDocument createEntity];
    self.d2 = [PUBDocument createEntity];
    self.d3 = [PUBDocument createEntity];
    self.d4 = nil;
    
    self.language_a_en = @{@"linked":@"t1", @"language":@"en", @"title":@"English"};
    self.language_a_de = @{@"linked":@"t1", @"language":@"de", @"title":@"Deutsch"};
    self.language_b_en = @{@"linked":@"t2", @"language":@"en", @"title":@"English"};
    
    self.d1.language = [PUBLanguage createOrUpdateWithDocument:self.d1 andDictionary:self.language_a_en];
    self.d2.language = [PUBLanguage createOrUpdateWithDocument:self.d2 andDictionary:self.language_a_de];
    self.d3.language = [PUBLanguage createOrUpdateWithDocument:self.d3 andDictionary:self.language_b_en];
}

- (void)testFetchAllDistinctDocuments {

    NSArray *documents = [PUBDocument fetchAllWithPrefferedLanguage:@"en"];
    
    XCTAssertTrue([documents containsObject:self.d1]);
    XCTAssertFalse([documents containsObject:self.d2]);
    XCTAssertTrue([documents containsObject:self.d3]);
}

- (void)testFetchAllDistinctDocumentsWithOneUequalToPrefferedLanguage {
    NSArray *documents = [PUBDocument fetchAllWithPrefferedLanguage:@"de"];
    
    XCTAssertFalse([documents containsObject:self.d1]);
    XCTAssertTrue([documents containsObject:self.d2]);
    XCTAssertTrue([documents containsObject:self.d3]); // No DE document version, return first doc.
}

- (void)testFetchAllDistinctDocumentsWithOneWithNilLanguage {
    self.d4 = [PUBDocument createEntity];
    
    NSArray *documents = [PUBDocument fetchAllWithPrefferedLanguage:@"en"];
    
    XCTAssertTrue([documents containsObject:self.d1]);
    XCTAssertFalse([documents containsObject:self.d2]);
    XCTAssertTrue([documents containsObject:self.d3]);
    XCTAssertTrue([documents containsObject:self.d4]);
}

@end
