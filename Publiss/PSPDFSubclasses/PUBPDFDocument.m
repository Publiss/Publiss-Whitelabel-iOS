//
//  PUBPDFDocument.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPDFDocument.h"
#import "PUBDocument+Helper.h"

@interface PUBDocumentProvider : PSPDFDocumentProvider
@end

@interface PUBPDFDocument ()
@property (nonatomic, assign) BOOL hasLoadedXFDFAnnotations;
@property (nonatomic, copy) NSString *productID;
@property (nonatomic, copy) NSArray *pageDimensions;

- (PUBDocument *)pubDocument;

@end

@implementation PUBPDFDocument

+ (instancetype)documentWithPUBDocument:(PUBDocument *)document {
    PUBPDFDocument *PDFDocument = [self documentWithBaseURL:document.localDocumentURL fileTemplate:@"%d.pdf" startPage:0 endPage:document.pageCount];
    PDFDocument.pageDimensions = document.dimensions;
    PDFDocument.productID = document.productID;
    
    [PDFDocument overrideClass:PSPDFDocumentProvider.class withClass:PUBDocumentProvider.class];
    [PDFDocument setDidCreateDocumentProviderBlock:^(PSPDFDocumentProvider *documentProvider) {
        // Hide warnings for missing files.
        [documentProvider setValue:@YES forKey:@"checkIfFileExists"];
        // Disable PDF annotation parsing (we use the file provider as a simple *container* that saves)
        documentProvider.annotationManager.fileAnnotationProvider.parsableTypes = PSPDFAnnotationTypeNone;

        // TODO: Currently annotation providers all point to the same file, which effectively loads all annotations on all pages.
        // We manually set the path here to work around this issue.
        PSPDFDocument *pdfDocument = documentProvider.document;
        NSUInteger absolutePage = [pdfDocument pageOffsetForDocumentProvider:documentProvider];
        NSString *annotationPath = [pdfDocument.dataDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"annotations_%tu.pspdfkit", absolutePage]];
        documentProvider.annotationManager.fileAnnotationProvider.annotationsPath = annotationPath;
    }];
    PDFDocument.title = document.title;
    //PDFDocument.autodetectTextLinkTypes = PSPDFTextCheckingTypeAll;
    PDFDocument.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;
//    PDFDocument.editableAnnotationTypes = [NSOrderedSet orderedSetWithObjects:PSPDFAnnotationStringHighlight, PSPDFAnnotationStringInk, PSPDFAnnotationStringNote, nil];

    [PDFDocument loadAnnotationsFromXFDF];

    return PDFDocument;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)restoreLocalAnnotations:(PUBPDFDocument *)pdfDocument {
    NSString *annotationSavePath = [self.class annotationBackupPathForPDFDocument:pdfDocument];
    if ([[NSFileManager defaultManager] fileExistsAtPath:annotationSavePath]) {
        NSError *copyError = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:annotationSavePath toPath:pdfDocument.dataDirectory error:&copyError]) {
            PUBLogError(@"Error copying files: %@", [copyError localizedDescription]);
        }
        [[NSFileManager defaultManager] removeItemAtPath:annotationSavePath error:nil];
    }
}

+ (void)saveLocalAnnotations:(PUBPDFDocument *)pdfDocument {
    NSString *annotationSavePath = [self.class annotationBackupPathForPDFDocument:pdfDocument];
    NSError *copyError = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:pdfDocument.dataDirectory toPath:annotationSavePath error:&copyError]) {
        PUBLogError(@"Error copying files: %@", [copyError localizedDescription]);
    }
}

+ (NSString *)annotationBackupPathForPDFDocument:(PUBPDFDocument *)pdfDocument {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"publiss/annotations_%@",  pdfDocument.productID]];
}

- (PUBDocument *)pubDocument {
    PUBAssertIfNotMainThread();
    return [PUBDocument findExistingPUBDocumentWithProductID:self.productID];
}

- (void)loadAnnotationsFromXFDF {
    if (!self.hasLoadedXFDFAnnotations) {
        NSURL *xfdfURL = self.pubDocument.localXFDFURL;
        if ([NSFileManager.defaultManager fileExistsAtPath:xfdfURL.path]) {
            NSInputStream *fileInput = [NSInputStream inputStreamWithURL:self.pubDocument.localXFDFURL];
            PSPDFXFDFParser *parser = [[PSPDFXFDFParser alloc] initWithInputStream:fileInput documentProvider:self.documentProviders.firstObject];
            [parser parseWithError:NULL];
            [self addAnnotations:parser.annotations];
            self.hasLoadedXFDFAnnotations = YES;
        }
    }
}

@end

@implementation PUBDocumentProvider

- (NSUInteger)pageCount {
    return 1;
}

- (PSPDFPageInfo *)pageInfoForPage:(NSUInteger)page pageRef:(CGPDFPageRef)pageRef {
    PUBPDFDocument *document = (PUBPDFDocument *)self.document;
    NSUInteger absolutePage = [document pageOffsetForDocumentProvider:self];
    NSArray *dimensions = document.pageDimensions;
    if (dimensions.count) {
        NSArray *pageSize = dimensions[dimensions.count > absolutePage ? absolutePage : 0];
        CGRect pageRect = CGRectMake(0.f, 0.f, [pageSize[0] floatValue], [pageSize[1] floatValue]);
        return [[PSPDFPageInfo alloc] initWithPage:page rect:pageRect rotation:0 documentProvider:self];
    }else {
        return [super pageInfoForPage:page pageRef:pageRef]; // fallback
    }
}

@end
