//
//  ViewController.m
//  SVFComboTableViewDemo
//
//  Created by Andrey on 11/08/15.
//  Copyright (c) 2015 _SVF_. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SVFComboTableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SVFComboTableViewDataSource

- (NSInteger) numberOfSectionsForComboTableView:(SVFComboTableView *)cTableView {
    return 1;
}

- (NSInteger) cTableView:(SVFComboTableView *)cTableView numberOfColumnsInSection:(NSInteger)section {
    return 30;
}

- (NSInteger) cTableView:(SVFComboTableView *)cTableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UIView *) cTableView:(SVFComboTableView *)cTableView viewForItemAtIndexPath:(SVFCTIndexPath *)indexPath withCellFrame:(CGRect)cellFrame {
    UIView * view = [[UIView alloc] initWithFrame:cellFrame];
    view.backgroundColor = indexPath.column % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    if (indexPath.column % 3 == 0) {
        view.backgroundColor = [UIColor greenColor];
    }
    
    return view;
}

- (UIView *) cTableView:(SVFComboTableView *)cTabelView viewForItemInHeaderViewForIndexPath:(SVFCTIndexPath *)indexPath withCellFrame:(CGRect)cellFrame {
    UIView * view = [[UIView alloc] initWithFrame:cellFrame];
    view.backgroundColor = indexPath.row % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    
    return view;
}

@end
