//
//  Article.h
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArticleStore.h"

typedef enum {
    noRequest,
    imageRequestType,
    thumbnailRequestType,
    bigThumbnailRequestType,
    sectionThumbnailRequestType
} articleImageRequestType;

@protocol ArticleImageLoaderDelegate;

@interface Article : NSObject <NSCoding, NSURLConnectionDataDelegate> {
    __strong NSURLConnection *connection;
    __strong NSMutableData *incomingData;
    articleImageRequestType requestType;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) UIImage *bigThumbnail;
@property (nonatomic, strong) UIImage *sectionThumbnail;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *section;
@property (nonatomic) newspaperType newspaperType;
@property (nonatomic, strong) NSString *ID;

@property (nonatomic, weak) NSObject <ArticleImageLoaderDelegate> *delegate;

- (id)initWithTitle:(NSString *)t author:(NSString *)a date:(NSDate *)d body:(NSString *)b imageURL:(NSURL *)url section:(NSString *)s newspaperType:(newspaperType)n ID:(NSString *)i;
- (NSComparisonResult)compare:(Article *)otherArticle;

- (NSURLConnection *)loadThumbnail;
- (NSURLConnection *)loadBigThumbnail;
- (NSURLConnection *)loadImage;
- (NSURLConnection *)loadSectionThumbnail;


@end

// make sure to check out what happens if the top top news image can't load

@protocol ArticleImageLoaderDelegate <NSObject>

@required

- (void)articleImageRequest:(articleImageRequestType)requestType didLoad:(Article *)anArticle;
- (void)articleImageRequest:(articleImageRequestType)requestType didHaveErrorLoading:(Article *)anArticle error:(NSString *)e;

- (int)widthForResize;
- (int)heightForResize;

@end