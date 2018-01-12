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
#import "MBProgressHUD+MJ.h"
@interface MZGameRoomVC ()<UICollectionViewDelegate,UICollectionViewDataSource,MZBluetoothManagerDelegate>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *gameRooms;
@property(nonatomic,copy)NSString *roomName;
@end

@implementation MZGameRoomVC

- (NSArray *)gameRooms {
    if (!_gameRooms) {
        _gameRooms = [NSArray array];
    }
    return _gameRooms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"游戏房间列表";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
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
        [weakSelf createGameRoom];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addDeviceBtn];
}

- (void)createGameRoom {
    __weak typeof(self)weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建房间" message:@"游戏房间名称" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入房间名称";
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = [[[alert textFields] firstObject] text];
        if (name.length == 0) {
            [MBProgressHUD showError:@"房间名称不能为空"];
            return ;
        }
        for (MZGameRoomModel *model in self.gameRooms) {
            if ([model.roomName isEqualToString:name]) {
                [MBProgressHUD showError:@"已存在相同的房间名"];
                return;
            }
        }
        [[MZBluetoothManager shareManager] creatGameWithName:name block:^(BOOL first) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MZGamePlayVC *vc = [[MZGamePlayVC alloc] init];
                vc.roomName = name;
                vc.isMeStep = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
        }];
    }];
    [alert addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.gameRooms = nil;
    [self.collectionView reloadData];
    MZBluetoothManager *manager = [MZBluetoothManager shareManager];
    manager.delegate = self;
    __weak typeof(self)weakSelf = self;
    [manager searchGameRoomCallBack:^(NSArray<MZGameRoomModel *> *rooms) {
        weakSelf.gameRooms = rooms;
        [weakSelf.collectionView reloadData];
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
    MZGameRoomModel *model = self.gameRooms[indexPath.row];
    self.roomName = model.roomName;
    [[MZBluetoothManager shareManager] joinToTheGameWithPeripheral:model.peripheral];
}

#pragma mark -MZBluetoothManagerDelegate
- (void)joinToGameSuccess {
    [[MZBluetoothManager shareManager] writeData:[NSString stringWithFormat:@"beginGame%@",[[UIDevice currentDevice] name]]];
    for (MZGameRoomModel *model in self.gameRooms) {
        if ([model.roomName isEqualToString:self.roomName]) {
            [[MZBluetoothManager shareManager] setCompetitor:model.peripheral.name];
        }
    }
    MZGamePlayVC *vc = [[MZGamePlayVC alloc] init];
    vc.roomName = self.roomName;
    vc.isMeStep = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)joinToGameFailure {
    [MBProgressHUD showError:@"进入游戏失败"];
}

@end
