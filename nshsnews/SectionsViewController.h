//
//  SectionsViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SectionNewsViewController;

// UICollectionViewDelegateFlowLayout is a subprotocol of UICollectionViewDelegate

@interface SectionsViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    SectionNewsViewController *newsSectionNewsViewController;
    SectionNewsViewController *featuresSectionNewsViewController;
    SectionNewsViewController *sportsSectionNewsViewController;
    SectionNewsViewController *opinionsSectionNewsViewController;
    SectionNewsViewController *centerfoldSectionNewsViewController;
    SectionNewsViewController *communitySectionNewsViewController;
}

@end
