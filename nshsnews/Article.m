//
//  Article.m
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "Article.h"

@implementation Article

@synthesize title, author, date, body, image, imageURL, thumbnail, bigThumbnail, sectionThumbnail, section, newspaperType, ID, delegate;

- (id)init {
    self = [super init];
    if (self) {
        self->requestType = noRequest;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        title = [aDecoder decodeObjectForKey:@"title"];
        author = [aDecoder decodeObjectForKey:@"author"];
        date = [aDecoder decodeObjectForKey:@"date"];
        body = [aDecoder decodeObjectForKey:@"body"];
        image = [aDecoder decodeObjectForKey:@"image"];
        thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
        bigThumbnail = [aDecoder decodeObjectForKey:@"bigThumbnail"];
        sectionThumbnail = [aDecoder decodeObjectForKey:@"sectionThumbnail"];
        imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        section = [aDecoder decodeObjectForKey:@"section"];
        self->newspaperType = (newspaperType)[aDecoder decodeIntForKey:@"newspaperType"];
        ID = [aDecoder decodeObjectForKey:@"ID"];
        
        self->requestType = noRequest;
    }
    return self;
}

- (id)initWithTitle:(NSString *)t author:(NSString *)a date:(NSDate *)d body:(NSString *)b imageURL:(NSURL *)url section:(NSString *)s newspaperType:(newspaperType)n ID:(NSString *)i {
    self = [super init];
    if (self) {
        title = t;
        author = a;
        date = d;
        body = b;
        imageURL = url;
        section = s;
        self->newspaperType = n;
        ID = i;
        
        self->requestType = noRequest;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:author forKey:@"author"];
    [aCoder encodeObject:date forKey:@"date"];
    [aCoder encodeObject:body forKey:@"body"];
    [aCoder encodeObject:imageURL forKey:@"imageURL"];
    [aCoder encodeObject:section forKey:@"section"];
    [aCoder encodeInt:newspaperType forKey:@"newspaperType"];
    [aCoder encodeObject:ID forKey:@"ID"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cacheImages"]) {
        [aCoder encodeObject:image forKey:@"image"];
        [aCoder encodeObject:thumbnail forKey:@"thumbnail"];
        [aCoder encodeObject:bigThumbnail forKey:@"bigThumbnail"];
        [aCoder encodeObject:sectionThumbnail forKey:@"sectionThumbnail"];
    }
}

- (NSComparisonResult)compare:(Article *)otherArticle {
    NSComparisonResult comparisonResult = [self.date compare:otherArticle.date];
    if (comparisonResult == NSOrderedAscending)
        return NSOrderedDescending;
    else if (comparisonResult == NSOrderedDescending)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

- (NSURLConnection *)loadThumbnail {
    if (requestType != noRequest)
        return nil;
    
    self->requestType = thumbnailRequestType;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nshsdenebola.com/wp-content/themes/Link/timthumb.php?src=%@&w=%d&h=%d&zc=1", [imageURL absoluteString], [delegate widthForResize], [delegate heightForResize]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    return connection;    
}

- (NSURLConnection *)loadImage {
    if (requestType != noRequest)
        return nil;
    
    self->requestType = imageRequestType;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nshsdenebola.com/wp-content/themes/Link/timthumb.php?src=%@&w=%d&h=%d&zc=1", [imageURL absoluteString], [delegate widthForResize], [delegate heightForResize]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    return connection;
}

- (NSURLConnection *)loadSectionThumbnail {
    if (requestType != noRequest)
        return nil;
    
    self->requestType = sectionThumbnailRequestType;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nshsdenebola.com/wp-content/themes/Link/timthumb.php?src=%@&w=%d&h=%d&zc=1", [imageURL absoluteString], [delegate widthForResize], [delegate heightForResize]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    return connection;
}

- (NSURLConnection *)loadBigThumbnail {
    if (requestType != noRequest)
        return nil;
    
    self->requestType = bigThumbnailRequestType;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nshsdenebola.com/wp-content/themes/Link/timthumb.php?src=%@&w=%d&h=%d&zc=1", [imageURL absoluteString], [delegate widthForResize], [delegate heightForResize]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    return connection;
}


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Article did receive response for image lookup");
    incomingData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // add the incoming chunk of data to the container we have
    [incomingData appendData:data];
    NSLog(@"data %@", [NSString stringWithUTF8String:[incomingData bytes]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    NSLog(@"articleConnectionDidFinishLoading");
    
    UIImage *imageFromData = [UIImage imageWithData:incomingData];

    switch (self->requestType) {
        case imageRequestType:
            image = imageFromData;
            break;
        case thumbnailRequestType:
            thumbnail = imageFromData;
            break;
        case bigThumbnailRequestType:
            bigThumbnail = imageFromData;
            break;
        case sectionThumbnailRequestType:
            sectionThumbnail = imageFromData;
            break;
        default:
            break;
    }
        
    if (!imageFromData)
        [delegate articleImageRequest:self->requestType didHaveErrorLoading:self error:@"connectionDidFinishLoading, but no image loaded."];
    else
        [delegate articleImageRequest:self->requestType didLoad:self];
    
    incomingData = nil;
    self->requestType = noRequest;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    incomingData = nil;    
    [delegate articleImageRequest:self->requestType didHaveErrorLoading:self error:[error localizedDescription]];
    self->requestType = noRequest;
}

@end
