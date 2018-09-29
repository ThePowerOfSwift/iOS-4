//
//  TestCollectionViewController.m
//  NDL_Category
//
//  Created by dzcx on 2018/9/20.
//  Copyright © 2018年 ndl. All rights reserved.
//

#import "TestCollectionViewController.h"
#import "DraggableCollectionView.h"
#import "TitleCell.h"

@interface TestCollectionViewController () <DraggableCollectionViewDelegate, DraggableCollectionViewDataSource>

@property (nonatomic, weak) DraggableCollectionView *draggableCollectionView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@end

@implementation TestCollectionViewController

- (NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
        
        for (NSInteger j = 0; j < 3; j++) {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSInteger i = 0; i < 50; i++) {
                NSString *str = [NSString stringWithFormat:@"%ld-%ld", j, i];
                [tempArray addObject:str];
            }
            [_dataSourceArray addObject:[tempArray copy]];
        }
    }
    return _dataSourceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumInteritemSpacing = 10;
    NSInteger column = 3;
    CGFloat itemWH = (self.view.width - 10 * 2 - 10 * (column - 1)) / column;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    
    // DraggableCollectionView
    DraggableCollectionView *draggableCollectionView = [[DraggableCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height / 2.0) collectionViewLayout:layout];
    draggableCollectionView.backgroundColor = [UIColor yellowColor];
//    draggableCollectionView.draggableDelegate = self;
//    draggableCollectionView.draggableDataSource = self;
    draggableCollectionView.delegate = self;
    draggableCollectionView.dataSource = self;
    [draggableCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TitleCell class]) bundle:nil] forCellWithReuseIdentifier:@"CellID"];
    [self.view addSubview:draggableCollectionView];
    self.draggableCollectionView = draggableCollectionView;
}

// test for editingModel
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    // editingModel
//    [_draggableCollectionView enterEditingModel];
//}

#pragma mark - DraggableCollectionViewDelegate
- (NSArray<NSIndexPath *> *)excludeIndexPathInDraggableCollectionView:(DraggableCollectionView *)collectionView
{
    // 每个section的最后一个cell都不能交换
    NSMutableArray *excludeIndexPathArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:50 - 1 inSection:i];
        [excludeIndexPathArray addObject:indexPath];
    }
    return excludeIndexPathArray;
}

- (void)draggableCollectionView:(DraggableCollectionView *)collectionView updatedDataSourceArray:(NSArray *)updatedDataSourceArray
{
    self.dataSourceArray = [updatedDataSourceArray mutableCopy];
}

#pragma mark - DraggableCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *subArray = self.dataSourceArray[section];
    return subArray.count;
}

- (NSArray *)dataSourceArrayOfCollectionView:(DraggableCollectionView *)collectionView
{
    return self.dataSourceArray;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellID" forIndexPath:indexPath];

    NSArray *subArray = self.dataSourceArray[indexPath.section];
    cell.titleLabel.text = subArray[indexPath.item];
    
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor blueColor];
    } else if (indexPath.section == 1) {
        cell.backgroundColor = [UIColor greenColor];
    } else if (indexPath.section == 2) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

@end
