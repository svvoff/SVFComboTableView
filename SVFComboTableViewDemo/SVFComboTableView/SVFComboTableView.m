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
#import "SVFComboTableViewCell.h"
#import "SVFTableViewDataSource.h"
#import "SVFComboTableViewConstants.h"



static NSString * kTableViewContentViewCellClassString = nil; //collection view table cell content view

@interface SVFComboTableView () <UITableViewDelegate, UICollectionViewDataSource,
                                  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *firstScrolled; // collection view witch reacting on touch
@property (nonatomic, strong) NSMutableArray *sectionsCvArray;
@property (nonatomic, assign) CGPoint contentOffsetPoint;
@property (nonatomic, strong) SVFTableViewDataSource *tableViewDataSource;

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
    _tableView.dataSource = self.tableViewDataSource;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    [self addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:SVFComboTableViewConstatnsTableViewCellXibName bundle:nil]
     forCellReuseIdentifier:SVFComboTableViewConstantsTableViewID];
}

- (void) configureSourceData {
    UITableViewCell * cell = [UITableViewCell new];
    kTableViewContentViewCellClassString = NSStringFromClass(cell.contentView.class);
    cell = nil;
    _sectionsCvArray = [NSMutableArray new];
    self.tableViewDataSource.sectionsCvArray = _sectionsCvArray;
    _contentOffsetPoint = CGPointZero;
    self.selectionType = SVFComboTableViewNonSelection;
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
//        [self configureCollectionViewForTargetView:headerView forSection:section];
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


#pragma mark - ColletionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource cTableView:self numberOfColumnsInSection:section];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SVFComboTableViewConstantsCollectionViewID forIndexPath:indexPath];
    
    
    
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
                    self.contentOffsetPoint = scrollView.contentOffset;
                    [item setContentOffset:self.contentOffsetPoint animated:NO];
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
                self.contentOffsetPoint = scrollView.contentOffset;
            }
        }
    }
}


#pragma mark - Properties

- (SVFTableViewDataSource *) tableViewDataSource {
    if (_tableViewDataSource) {
        return _tableViewDataSource;
    }
    _tableViewDataSource = [SVFTableViewDataSource new];
    _tableViewDataSource.cTableView = self;
    return _tableViewDataSource;
}

- (void) setDataSource:(id<SVFComboTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.tableViewDataSource.dataSource = dataSource;
}

- (void) setContentOffsetPoint:(CGPoint)contentOffsetPoint {
    _contentOffsetPoint = contentOffsetPoint;
    self.tableViewDataSource.contentOffsetPoint = contentOffsetPoint;
}

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
