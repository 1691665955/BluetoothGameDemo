//
//  MZGameRoomVC.m
//  GameDemo
//
//  Created by 曾龙 on 17/4/21.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import "MZGameRoomVC.h"
#import "Header.h"
#import "MZGameRoomCell.h"
#import "MZGamePlayVC.h"
#import "MZBluetoothManager.h"
@interface MZGameRoomVC ()<UICollectionViewDelegate,UICollectionViewDataSource,MZBluetoothManagerDelegate>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *gameRooms;
@end

@implementation MZGameRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"游戏房间列表";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    self.gameRooms = [[NSMutableArray alloc] init];
    MZGameRoomModel *model = [[MZGameRoomModel alloc] init];
    model.roomName = @"666";
    [self.gameRooms addObject:model];
    
    //菜单列表，collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100*SCALE, 100*SCALE);
    layout.minimumInteritemSpacing = 10*SCALE;
    layout.sectionInset = UIEdgeInsetsMake(20*SCALE, 20*SCALE, 20*SCALE, 20*SCALE);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[MZGameRoomCell class] forCellWithReuseIdentifier:@"GameRoomCell"];

    __weak typeof(self)weakSelf = self;
    MZButton *addDeviceBtn = [[MZButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40) andNormalTitle:nil andSelectedTitle:nil andTitlteColor:nil andNBImageName:@"btn_添加设备_n" andHBImageName:@"btn_添加设备_p" andSBName:nil andClickedBlock:^(MZButton *sender) {
        [weakSelf addGameRoom];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addDeviceBtn];
}

- (void)addGameRoom {
    __weak typeof(self)weakSelf = self;
    [[MZBluetoothManager shareManager] creatGameWithName:@"666" block:^(BOOL first) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MZGamePlayVC *vc = [[MZGamePlayVC alloc] init];
            vc.model = self.gameRooms[0];
            vc.isMeStep = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
}

#pragma mark --UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gameRooms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"GameRoomCell";
    MZGameRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[MZGameRoomCell alloc] initWithFrame:CGRectMake(0, 0, 100*SCALE, 100*SCALE)];
    }
    cell.model = self.gameRooms[indexPath.row];
    return cell;
}

#pragma mark --UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MZBluetoothManager *manager = [MZBluetoothManager shareManager];
    manager.delegate = self;
    [manager searchGame];
}

- (void)searchGameSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        MZGamePlayVC *vc = [[MZGamePlayVC alloc] init];
        vc.model = self.gameRooms[0];
        vc.isMeStep = NO;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)getData:(NSString *)data {
    NSLog(@"%@",data);
}

@end
