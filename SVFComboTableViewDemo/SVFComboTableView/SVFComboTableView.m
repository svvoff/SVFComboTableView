//
//  ComboTableView.m
//  SVFComboTableViewDemo
//
//  Created by Andrei Sorokin on 03/07/15.
//  Copyright © 2016 _SVF_. All rights reserved.
//

#import "SVFComboTableView.h"
#import <UIKit/UICollectionView.h>
#import <UIKit/UICollectionViewFlowLayout.h>
#import <UIKit/UICollectionViewCell.h>


static NSString * const tableViewCellId = @"tableViewCellId";
static NSString * const collectionViewCellId = @"collectionViewCellId";
static NSString * kTableViewContentViewCellClassString = nil; //collection view table cell content view

@interface SVFComboTableView () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource,
                                  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *firstScrolled; // collection view witch reacting on touch
@property (nonatomic, strong) NSMutableArray *sectionsCvArray;
@property (nonatomic, assign) CGPoint contentOffsetPoint;

@end

@implementation SVFComboTableView {
  
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self createTableViewWithFrame:frame];
    [self configureSourceData];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self createTableViewWithFrame:self.frame];
    [self configureSourceData];
    return self;
}

- (void) createTableViewWithFrame:(CGRect) frame {
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    [self addSubview:_tableView];
    [self configureTableView];
}

- (void) configureTableView {
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellId];
}

- (void) configureSourceData {
    UITableViewCell * cell = [UITableViewCell new];
    kTableViewContentViewCellClassString = NSStringFromClass(cell.contentView.class);
    cell = nil;
    _sectionsCvArray = [NSMutableArray new];
    _contentOffsetPoint = CGPointZero;
    self.selectionType = SVFComboTableViewNonSelection;
}


#pragma mark - TableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSource) {
        return [self.dataSource numberOfSectionsForComboTableView:self];
    } else {
        return 0;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return [self.dataSource cTableView:self numberOfRowsInSection:section];
    } else {
        return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellId forIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(cTableView:colorForTableViewCellForIndexPath:)]) {
        SVFCTIndexPath * index = [SVFCTIndexPath indexPathForRow:indexPath.row column:0 inSection:indexPath.section];
        UIColor * cellColor = [self.delegate cTableView:self colorForTableViewCellForIndexPath:index];
        cell.backgroundColor = cellColor;
    }
    [self configureCollectionViewForTargetView:cell.contentView forSection:indexPath.section];
    
    return cell;
}

#pragma mark - TableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = 44.f;
    if ([self.dataSource respondsToSelector:@selector(cTableView:heightForRow:inSection:)]) {
        
        h = [self.dataSource cTableView:self heightForRow:indexPath.row inSection:indexPath.section];
    }
    return h;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat h = 44.f;
    if ([self.delegate respondsToSelector:@selector(cTableView:heightForHeaderInSection:)]) {
        h = [self.delegate cTableView:self heightForHeaderInSection:section];
        return h;
    } else if (![self.delegate respondsToSelector:@selector(cTableView:viewForHeaderInSection:)]) {
        h = .01f;
        return h;
    }
    return h;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (![self.delegate respondsToSelector:@selector(cTableView:viewForHeaderInSection:)]) {
        return nil;
    } else {
        UIView * headerView = [self.delegate cTableView:self viewForHeaderInSection:section];
        [self configureCollectionViewForTargetView:headerView forSection:section];
        return headerView;
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(cTableView:commitEditingStyle:forRow:inSection:)]) {
        [self.delegate cTableView:self commitEditingStyle:editingStyle forRow:indexPath.row inSection:indexPath.section];
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(cTableView:canEditRow:inSection:)]) {
        return [self.delegate cTableView:self canEditRow:indexPath.row inSection:indexPath.section];
    } else if ([self.delegate respondsToSelector:@selector(cTableView:commitEditingStyle:forRow:inSection:)]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Configure

- (void) configureCollectionViewForTargetView:(UIView *) targetView forSection:(NSInteger) section {
    CGRect frameForCV = CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
    UICollectionView * cv = [self configureCollectionViewWithFrame:frameForCV];
    
    NSMutableArray * cvSectionArray = nil;
    if (section < _sectionsCvArray.count) {
        cvSectionArray = [_sectionsCvArray[section] mutableCopy];
    } else {
        cvSectionArray = [NSMutableArray new];
    }
    
    
    for (UIView * item in targetView.subviews) {
        if ([item isKindOfClass:[UICollectionView class]]) {
            [item removeFromSuperview];
            if ([cvSectionArray containsObject:item]) {
                [cvSectionArray removeObject:item];
            }
        }
    }
    
    [cvSectionArray addObject:cv];
    if (_sectionsCvArray.count == section) {
        [_sectionsCvArray insertObject:cvSectionArray atIndex:section];
    } else {
        [_sectionsCvArray replaceObjectAtIndex:section withObject:cvSectionArray];
    }
    //
    [targetView addSubview:cv];
}

- (UICollectionView *) configureCollectionViewWithFrame:(CGRect) frame {
    UICollectionViewFlowLayout * layout = [self configureCollectionViewFlowLayoutWithFrame:frame];
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellId];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [collectionView setContentOffset:_contentOffsetPoint animated:YES];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return collectionView;
}

- (UICollectionViewFlowLayout *) configureCollectionViewFlowLayoutWithFrame:(CGRect) frame {
    UICollectionViewFlowLayout * cvfl = [[UICollectionViewFlowLayout alloc] init];
    [cvfl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [cvfl setItemSize:CGSizeMake(frame.size.width, frame.size.height)];
    cvfl.minimumInteritemSpacing = 0.f;
    cvfl.minimumLineSpacing = 0.f;
    return cvfl;
}

#pragma mark - ColletionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource cTableView:self numberOfColumnsInSection:section];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellId forIndexPath:indexPath];
    
    
    
    UIView * tableContentView = collectionView.superview;
    NSIndexPath * index = [self indexPathForTableViewCell:tableContentView];
    CGRect cellFrame = cell.bounds;
    
    if (!index && [self.dataSource respondsToSelector:@selector(cTableView:viewForItemInHeaderViewForIndexPath:withCellFrame:)]) {
        NSInteger sectionNumber = [self sectionNumberForCollectionView:collectionView];
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow: - 1 column:indexPath.row inSection:sectionNumber];
        UIView * viewInCell = [self.dataSource cTableView:self viewForItemInHeaderViewForIndexPath:ctIndexPath withCellFrame:cellFrame];
        [self clearSubviewsForView:cell forClass:[viewInCell class]];
        if (viewInCell) {
            [cell addSubview:viewInCell];
        }
    }
    
    if ([NSStringFromClass(collectionView.superview.class) isEqualToString:kTableViewContentViewCellClassString]) {
        [self clearSubviewsForView:cell forClass:[UIView class]];
        
        if (index) {
            SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:index.row column:indexPath.row inSection:index.section];
            UIView * viewInCell = [self.dataSource cTableView:self viewForItemAtIndexPath:ctIndexPath withCellFrame:cellFrame];
            if (viewInCell) {
                [cell addSubview:viewInCell];
            }
        }
    }
    
    return cell;
}

- (NSIndexPath *) indexPathForCollectionView:(UICollectionView *) collectionView {
    UIView * tableCell = collectionView.superview;
    return [self indexPathForTableViewCell:tableCell];
}

- (NSIndexPath *) indexPathForTableViewCell:(UIView *) tableCellContentView {
    if ([tableCellContentView.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath * index = [_tableView indexPathForRowAtPoint:tableCellContentView.superview.center];
        return index;
    } else {
        return nil;
    }
}

- (void) clearSubviewsForView:(UIView *) targetView forClass:(Class) class{
    for (UIView * item in targetView.subviews) {
        if ([item isKindOfClass:class]) {
            [item removeFromSuperview];
        }
    }
}

- (SVFCTIndexPath *) ctIndexPathForTableIndexPath:(NSIndexPath *) tableIP andCollectionIndexPath:(NSIndexPath *) collectionIP collectionView:(UICollectionView *) collectionView {
    if (tableIP && collectionIP) {
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:tableIP.row column:collectionIP.row inSection:tableIP.section];
        return ctIndexPath;
    } else if (!tableIP && collectionIP) {
        NSInteger section = [self sectionNumberForCollectionView:collectionView];
        
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:-1 column:collectionIP.row inSection:section];
        return ctIndexPath;
    } else {
        return nil;
    }
}

- (NSInteger) sectionNumberForCollectionView:(UICollectionView *) collectionView {
    NSInteger section = - 1;
    
    for (int i = 0; i < _sectionsCvArray.count; ++i) {
        NSArray * sectionArray = _sectionsCvArray[i];
        for (int j = 0; j < sectionArray.count; ++j) {
            UICollectionView * cv = sectionArray[j];
            if ([cv isEqual:collectionView]) {
                section = i;
                break;
            }
        }
        if (section != -1) {
            break;
        }
    }
    return section;
}

#pragma mark - CollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * index = [self indexPathForCollectionView:collectionView];
    SVFCTIndexPath * ctIndexPath = [self ctIndexPathForTableIndexPath:index andCollectionIndexPath:indexPath collectionView:collectionView];
    switch (self.selectionType) {
        case SVFComboTableViewNonSelection: {
            
        }
            break;
        case SVFComboTableViewItemSelection: {
            
        }
            break;
        case SVFComboTableViewRowSelection: {
            [_tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
            [_tableView deselectRowAtIndexPath:index animated:YES];
        }
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(cTableView:didSelectItemForIndexPath:)] && ctIndexPath.row >= 0) {
        [self.delegate cTableView:self didSelectItemForIndexPath:ctIndexPath];
    }
    if ([self.delegate respondsToSelector:@selector(cTableView:didSelectHeaderItemForColumn:inSection:)] && ctIndexPath.row == -1) {
        [self.delegate cTableView:self didSelectHeaderItemForColumn:ctIndexPath.column inSection:ctIndexPath.section];
    }
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = collectionView.frame.size.height;
    CGFloat w = 50.f;
    NSIndexPath * index = [self indexPathForCollectionView:collectionView];
    SVFCTIndexPath * ctIndexPath = [self ctIndexPathForTableIndexPath:index andCollectionIndexPath:indexPath collectionView:collectionView];
    if ([self.dataSource respondsToSelector:@selector(cTableView:widthForColumnAtIndexPath:)] && ctIndexPath) {
        w = [self.dataSource cTableView:self widthForColumnAtIndexPath:ctIndexPath];
    }
    
    return CGSizeMake(w, h);
}


#pragma mark - ScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _firstScrolled = nil;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!_firstScrolled) {
        _firstScrolled = (UICollectionView *) scrollView;
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _firstScrolled = nil;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        if (!_firstScrolled) {
            _firstScrolled = (UICollectionView *) scrollView;
        }
        
        NSArray * selectedSection = [self getArrayForSelectedCollectionView:_firstScrolled];
        
        if ([scrollView isEqual:_firstScrolled]) {
            for (UICollectionView * item in selectedSection) {
                if (![item isEqual:_firstScrolled]) {
                    _contentOffsetPoint = scrollView.contentOffset;
                    [item setContentOffset:_contentOffsetPoint animated:NO];
                }
            }
            _firstScrolled = nil;
        }
    }
}

- (NSArray *) getArrayForSelectedCollectionView:(UICollectionView *) selectedCV {
    NSArray * selectedSection = nil;
    
    for (NSArray * section in _sectionsCvArray) {
        for (UICollectionView * scrolledCV in section) {
            if ([scrolledCV isEqual:_firstScrolled]) {
                selectedSection = section;
                break;
            }
        }
        if (selectedSection) {
            break;
        }
    }
    
    return selectedSection;
}

- (void) setContentOffsetForScrollView:(UIScrollView *) scrollView {
    
    NSArray * arrayWithCV = [self getArrayForSelectedCollectionView:_firstScrolled];
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        
        for (UICollectionView * item in arrayWithCV) {
            if (![item isEqual:scrollView]) {
                [item setContentOffset:scrollView.contentOffset animated:NO];
                _contentOffsetPoint = scrollView.contentOffset;
            }
        }
    }
}


#pragma mark - Properties


#pragma mark - Other

- (void) reloadData {
    [_tableView reloadData];
}

- (void) addSubview:(UIView *)view {
    if ([view isKindOfClass:[UIRefreshControl class]]) {
        [_tableView addSubview:view];
    } else {
        [super addSubview:view];
    }
}

- (void) setEditing:(BOOL) editing animated:(BOOL) animated {
    [_tableView setEditing:editing animated:animated];
}

- (void) deleteRow:(NSInteger)row inSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
}


@end
