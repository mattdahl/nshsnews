//
//  SectionsViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "SectionsViewController.h"
#import "SectionCollectionViewCell.h"
#import "SectionNewsViewController.h"
#import "ArticleStore.h"

@implementation SectionsViewController

static NSArray *sectionTitles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UICollectionViewFlowLayout *l = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:l];
    if (self) {
        [self setTitle:@"Sections"]; // used for tabBarItem
        [self.tabBarItem setImage:[UIImage imageNamed:@"SectionsTabBarImage"]];
        
        sectionTitles = [NSArray arrayWithObjects:@"News", @"Features", @"Sports", @"Opinions", @"Centerfold", @"Community", nil];
        
        newsSectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                    bundle:nil
                                                                              sectionTitle:[sectionTitles objectAtIndex:0]];
        featuresSectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                        bundle:nil
                                                                                  sectionTitle:[sectionTitles objectAtIndex:1]];
        sportsSectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                      bundle:nil
                                                                                sectionTitle:[sectionTitles objectAtIndex:2]];
        opinionsSectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                        bundle:nil
                                                                                  sectionTitle:[sectionTitles objectAtIndex:3]];
        centerfoldSectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                          bundle:nil
                                                                                    sectionTitle:[sectionTitles objectAtIndex:4]];
        communitySectionNewsViewController = [[SectionNewsViewController alloc] initWithNibName:@"SectionNewsViewController"
                                                                                         bundle:nil
                                                                                   sectionTitle:[sectionTitles objectAtIndex:5]];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[SectionCollectionViewCell class] forCellWithReuseIdentifier:@"SectionCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell.sectionTitle setText:[sectionTitles objectAtIndex:indexPath.row]];
    Article *a;
    
    switch (indexPath.row) {
        case 0:
            a = [newsSectionNewsViewController firstArticle];
            break;
        case 1:
            a = [featuresSectionNewsViewController firstArticle];
            break;
        case 2:
            a = [sportsSectionNewsViewController firstArticle];
            break;
        case 3:
            a = [opinionsSectionNewsViewController firstArticle];
            break;
        case 4:
            a = [centerfoldSectionNewsViewController firstArticle];
            break;
        case 5:
            a = [communitySectionNewsViewController firstArticle];
            break;
        default:
            break;
    }
    
    if (!a) {
        [[cell backgroundImageView] setImage:[UIImage imageNamed:@"LionsRoarSectionThumbnail"]];
        return cell;
    }
    else {
        [cell setArticle:a];
        [a setDelegate:cell];
        [cell.backgroundImageView setImage:nil]; // clears old thumbnail
        [cell setNeedsDisplay];

        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:newsSectionNewsViewController animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:featuresSectionNewsViewController animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:sportsSectionNewsViewController animated:YES];
            break;
        case 3:
            [self.navigationController pushViewController:opinionsSectionNewsViewController animated:YES];
            break;
        case 4:
            [self.navigationController pushViewController:centerfoldSectionNewsViewController animated:YES];
            break;
        case 5:
            [self.navigationController pushViewController:communitySectionNewsViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width/2-4, 160);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 2, 0, 2); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
