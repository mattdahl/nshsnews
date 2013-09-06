//
//  SearchViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    __strong UITapGestureRecognizer *tapRecognizer;
    bool *sourceOptions;
    
    UISwitch *lionsRoarSwitch;
    UISwitch *denebolaSwitch;
}

@end
