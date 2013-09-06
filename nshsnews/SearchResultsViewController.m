//
//  SearchResultsViewController.m
//  nshsnews
//
//  Created by Matt Dahl on 6/2/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "Article.h"
#import "ArticleCell.h"
#import "ArticleViewController.h"

@implementation SearchResultsViewController

static NSArray *articles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articles:(NSArray *)a {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self.navigationItem setTitle:@"Search Results"];
        
        articles = a;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ArticleCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ArticleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([articles count] == 0)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        Article *a = [articles objectAtIndex:indexPath.row];
        
        [(ArticleCell *)cell setArticle:a];
        [(ArticleCell *)cell setArticleTitle:a.title];
        [a setDelegate:(ArticleCell *)cell];
        [[(ArticleCell *)cell thumbnailImageView] setImage:nil]; // clears old thumbnail
        [(ArticleCell *)cell setNeedsDisplay];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *formattedDate = [formatter stringFromDate:a.date];
        [[(ArticleCell *)cell articleDate] setText:formattedDate];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *navBarTitle = [NSString stringWithFormat:@"%d of %d", indexPath.row+1, [articles count]];
    ArticleViewController *avc = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController"
                                                                         bundle:nil
                                                                        article:[articles objectAtIndex:indexPath.row]
                                                                    navBarTitle:navBarTitle];
    [[articles objectAtIndex:indexPath.row] setDelegate:avc]; // passes the delegate
    [self.navigationController pushViewController:avc animated:YES];
}

@end
