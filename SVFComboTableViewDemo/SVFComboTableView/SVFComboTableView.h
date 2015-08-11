//
//  ComboTableView.h
//  bachmann crm mobile app bps2
//
//  Created by Andrey on 03/07/15.
//  Copyright (c) 2015 Kirill Pyulzyu. All rights reserved.
//

@protocol SVFComboTableViewDelegate;
@protocol SVFComboTableViewDataSource;

#import <UIKit/UIKit.h>
#import "SVFCTIndexPath.h"

@interface SVFComboTableView : UIView

@property IBOutlet id <SVFComboTableViewDataSource> dataSource;
@property IBOutlet id <SVFComboTableViewDelegate> delegate;

@end

#pragma mark - DataSource

@protocol SVFComboTableViewDataSource <NSObject>

@required
- (NSInteger) numberOfSectionsForComboTableView:(SVFComboTableView *) cTableView;
- (NSInteger) cTableView:(SVFComboTableView *) cTableView numberOfRowsInSection:(NSInteger) section;
- (NSInteger) cTableView:(SVFComboTableView *) cTableView numberOfColumnsInSection:(NSInteger) section;
- (UIView *) cTableView:(SVFComboTableView *) cTableView viewForItemAtIndexPath:(SVFCTIndexPath *) indexPath withCellFrame:(CGRect) cellFrame;
- (UIView *) cTableView:(SVFComboTableView *) cTabelView viewForItemInHeaderViewForIndexPath:(SVFCTIndexPath *) indexPath withCellFrame:(CGRect) cellFrame;

@optional
- (CGFloat) cTableView:(SVFComboTableView *) cTableView heightForRow:(NSInteger) row inSection:(NSInteger) section;
- (CGFloat) cTableView:(SVFComboTableView *) cTableView widthForColumnAtIndexPath:(SVFCTIndexPath *) indexPath;

@end

#pragma mark - Delegate

@protocol SVFComboTableViewDelegate <NSObject>

@optional
- (UIView *) cTableView:(SVFComboTableView *) cTableView viewForHeaderInSection:(NSInteger) section;
- (CGFloat) cTableView:(SVFComboTableView *) cTableView heightForHeaderInSection:(NSInteger) section;

@end