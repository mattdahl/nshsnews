//
//  ArticleViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AppDelegate.h"
#import "ArticleViewController.h"
#import "Article.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@implementation ArticleViewController

@synthesize article, contentSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article *)a navBarTitle:(NSString *)t {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        adjusted = 0;
        article = a;
        
        [self setTitle:t];
        [self.view setBackgroundColor:[UIColor whiteColor]];
       // [bodyView setArticleBody:article.body];

        UIImage *facebookImage = [UIImage imageNamed:@"FacebookIcon"];
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [facebookButton setFrame:CGRectMake(0, 0, facebookImage.size.width, facebookImage.size.height)];
        [facebookButton setImage:facebookImage forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(presentFacebookShareSheet) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *twitterImage = [UIImage imageNamed:@"TwitterIcon"];
        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitterButton setBounds:CGRectMake(0, 0, twitterImage.size.width, twitterImage.size.height)];
        [twitterButton setImage:twitterImage forState:UIControlStateNormal];
        [twitterButton addTarget:self action:@selector(presentTwitterShareSheet) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:facebookButton], [[UIBarButtonItem alloc] initWithCustomView:twitterButton], nil]];
        
        if (article.image)
            [activityIndicatorView stopAnimating];
        else
            [self.view bringSubviewToFront:activityIndicatorView];
                
     //   tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTabBar)];
     //   [self.view addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)setContentSize:(CGSize)size {
    if (article.image != [UIImage imageNamed:@"NoImage"])
        contentSize = CGSizeMake(size.width, size.height+330);
    else
        contentSize = CGSizeMake(size.width, size.height+150);
    [(UIScrollView *)self.view setContentSize:contentSize];
    [self.view setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    oldOffset = [(UIScrollView *)self.view contentOffset];
    [(UIScrollView *)self.view setContentOffset:CGPointMake(0,0)];
    
    [(UIScrollView *)self.view setContentSize:contentSize];
    
    if (!article.image)
        [article loadImage];
    else if ([article.image isEqual:[UIImage imageNamed:@"NoImage"]]) {
        [imageView setHidden:YES];
        [bodyView setFrame:CGRectMake(bodyView.frame.origin.x, 175, bodyView.frame.size.width, bodyView.frame.size.height)];
        [mastheadView setFrame:CGRectMake(mastheadView.frame.origin.x, 140, mastheadView.frame.size.width, mastheadView.frame.size.height)];
        [self.view setNeedsDisplay];
        [activityIndicatorView stopAnimating];
    }
    else if (!imageView.image) {
        [imageView setImage:article.image];
        [imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [imageView.layer setBorderWidth:1.0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, bodyView.frame.size.height+320)];
    [(UIScrollView *)self.view setContentSize:contentSize];
    [(UIScrollView *)self.view setContentOffset:oldOffset];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer in the navigation stack
        [article setDelegate:nil];
        NSArray *navigationViewControllers = [self.navigationController viewControllers];
        UITableViewController *pushingViewController;
        for (UIViewController *vc in navigationViewControllers)
            if ([vc isKindOfClass:[UITableViewController class]]) {
                pushingViewController = (UITableViewController *)vc;
                break;
            }        
        [pushingViewController.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)displayArticleText {
    [articleTitle setText:article.title];
    [articleTitle setFont:[UIFont fontWithName:@"Georgia-Bold" size:22.0]];
    [articleTitle setNumberOfLines:0];
        
    NSMutableString *byline = [[NSMutableString alloc] initWithString:@"By "];
    [byline appendString:article.author];
    [articleAuthor setText:byline];
    [articleAuthor setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    [articleAuthor setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.8]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    [articleDate setText:[[formatter stringFromDate:article.date] uppercaseString]];
    [articleDate setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    [articleDate setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.8]];
    
    [bodyView setText:article.body];
    CGSize maximumBodySize = CGSizeMake(290, FLT_MAX);
    CGSize bodySize = [article.body sizeWithFont:[UIFont fontWithName:@"Georgia" size:14.5]
                               constrainedToSize:maximumBodySize
                                   lineBreakMode:NSLineBreakByWordWrapping];
    [bodyView setFrame:CGRectMake(bodyView.frame.origin.x, bodyView.frame.origin.y, bodySize.width, bodySize.height)];
    [self setContentSize:CGSizeMake(bodySize.width, bodySize.height)];
    
    [self.view setNeedsDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayArticleText];
    
    if (article.newspaperType == lionsRoarNewspaperType)
        [mastheadView setImage:[UIImage imageNamed:@"LionsRoarMastheadSmall"]];
    else if (article.newspaperType == denebolaNewspaperType)
        [mastheadView setImage:[UIImage imageNamed:@"DenebolaMastheadSmall"]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Adjusts view for iOS 7
    if (adjusted < 2) {
        NSLog(@"adjusting...");
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        adjusted++;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   // imageView.image = nil;
   // mastheadView.image = nil;
}

#pragma mark - ArticleImageLoaderDelegate methods

- (void)articleImageRequest:(articleImageRequestType)requestType didLoad:(Article *)anArticle {
    if (requestType == imageRequestType) {
        [imageView setImage:anArticle.image];
        [imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [imageView.layer setBorderWidth:1.0];
        [imageView setNeedsDisplay];
        [activityIndicatorView stopAnimating];
    }
}

- (void)articleImageRequest:(articleImageRequestType)requestType didHaveErrorLoading:(Article *)anArticle error:(NSString *)e {
    [imageView setHidden:YES];
    [anArticle setImage:[UIImage imageNamed:@"NoImage"]];
    [bodyView setFrame:CGRectMake(bodyView.frame.origin.x, bodyView.frame.origin.y-180, bodyView.frame.size.width, bodyView.frame.size.height)];
    [mastheadView setFrame:CGRectMake(mastheadView.frame.origin.x, mastheadView.frame.origin.y-180, mastheadView.frame.size.width, mastheadView.frame.size.height)];
    [(UIScrollView *)self.view setContentSize:CGSizeMake([(UIScrollView *)self.view contentSize].width, [(UIScrollView *)self.view contentSize].height-180)];
    [self.view setNeedsDisplay];
    [activityIndicatorView stopAnimating];
}

- (int)widthForResize {
    if ([AppDelegate isRetina])
        return 2*290;
    else
        return 290;
}

- (int)heightForResize {
    if ([AppDelegate isRetina])
        return 2*180;
    else
        return 180;
}

#pragma mark - Social media

- (void)presentFacebookShareSheet {
    SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    facebookSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
        
        //  dismiss the share sheet
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Facebook Share Sheet has been dismissed.");
            }];
        });
    };
    
    //  Set the initial body of the post
    [facebookSheet setInitialText:@"#NSHSNews\n"];
    
    if (![facebookSheet addURL:[self articleURL]])
        NSLog(@"Unable to add the URL!");
    
    //  Presents the Facebook Share Sheet to the user
    [self presentViewController:facebookSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
    
}

- (void)presentTwitterShareSheet {
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
        
        //  dismiss the Tweet Sheet
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Tweet Sheet has been dismissed.");
            }];
        });
    };
    
    if (![tweetSheet addURL:[self articleURL]])
        NSLog(@"Unable to add the URL!");
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"#NSHSNews\n"];
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}

- (NSURL *)articleURL {
    if (article.newspaperType == lionsRoarNewspaperType) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thelionsroar.com/article.php?id=%@", article.ID]];
    }
    else if (article.newspaperType == denebolaNewspaperType) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nshsdenebola.com/?page_id=%@", article.ID]];
    }
    
    return nil;
}

@end
