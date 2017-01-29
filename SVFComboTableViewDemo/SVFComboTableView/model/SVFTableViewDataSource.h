//
//  TableViewDataSource.h
//  SVFComboTableViewDemo
//
//  Created by Andrey Sorokin on 29/01/2017.
//  Copyright © 2017 _SVF_. All rights reserved.
//

#import <UIKit/UITableView.h>
#import <UIKit/UICollectionView.h>
#import "SVFComboTableViewDataSource.h"

@class SVFComboTableView;

@interface SVFTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak) id<SVFComboTableViewDataSource> dataSource;
@property (nonatomic, weak) id<UICollectionViewDelegate, UICollectionViewDataSource> cTableView;

@property (nonatomic, weak) NSMutableArray *sectionsCvArray;
@property (nonatomic, assign) CGPoint contentOffsetPoint;


@end
