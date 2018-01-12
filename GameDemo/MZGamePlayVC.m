//
//  MZGamePlayVC.m
//  GameDemo
//
//  Created by 曾龙 on 17/4/21.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import "MZGamePlayVC.h"
#import "Header.h"
#import "MBProgressHUD+MJ.h"
#import "MZBluetoothManager.h"
@interface MZGamePlayVC ()<MZBluetoothManagerDelegate>
@property(nonatomic,strong)NSMutableDictionary *chessDic;
@property(nonatomic,assign)BOOL isWhiteChess;
@property(nonatomic,strong)UIView *chessView;

@property(nonatomic,strong)UIView *lastView;
@property(nonatomic,copy)NSString *lastKey;

@property(nonatomic,assign)BOOL isFinished;

@property(nonatomic,strong)MZLabel *blackPlayerLB;
@property(nonatomic,strong)MZLabel *blackChessCountLB;
@property(nonatomic,strong)MZLabel *whitePlayerLB;
@property(nonatomic,strong)MZLabel *whiteChessCountLB;
@property(nonatomic,strong)MZLabel *resultLB;

@property(nonatomic,assign)BOOL hasFriendJoined;
@end

@implementation MZGamePlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.roomName;
    self.chessDic = [[NSMutableDictionary alloc] init];
    self.isWhiteChess = !self.isMeStep;
    [self drawBackground];
    [[MZBluetoothManager shareManager] setDelegate:self];
    if (self.isWhiteChess) {
        [MBProgressHUD showError:@"游戏开始"];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [btn setImage:[UIImage imageNamed:@"btn_返回_n"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"btn_返回_p"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(leftBarItemClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)leftBarItemClicked {
    if ([[MZBluetoothManager shareManager] isCentral] && !self.hasFriendJoined) {
        [[MZBluetoothManager shareManager] advitisTheRoomRemoved];
        [self back];
        return;
    }
    if (self.isFinished) {
        [[MZBluetoothManager shareManager] writeData:@"leaveRoom"];
        [self back];
        [self performSelector:@selector(disConnect) withObject:nil afterDelay:1.0f];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该局输赢未定，请问您是否确认离开房间？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[MZBluetoothManager shareManager] writeData:@"leaveRoom"];
            if (![[MZBluetoothManager shareManager] isCentral]) {
                [[MZBluetoothManager shareManager] disConnect];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:okAction];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)disConnect {
    if (![[MZBluetoothManager shareManager] isCentral]) {
        [[MZBluetoothManager shareManager] disConnect];
    }
}

//初始化棋盘
- (void)drawBackground {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, SCREEN_W-20, SCREEN_W-20)];
    bgView.backgroundColor = [UIColor orangeColor];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
    __weak typeof(self)weakSelf = self;
    //悔棋和重开
    MZButton *backBtn = [[MZButton alloc] initWithFrame:CGRectMake(80*SCALE, CGRectGetMaxY(bgView.frame)+30*SCALE, 80*SCALE, 50*SCALE) andNormalTitle:@"悔棋" andSelectedTitle:nil andTitlteColor:[UIColor blackColor] andBackgroundColor:[UIColor orangeColor] andClickedBlock:^(MZButton *sender) {
        [weakSelf backLastStepRequest];
    }];
    [self.view addSubview:backBtn];
    
    MZButton *resetBtn = [[MZButton alloc] initWithFrame:CGRectMake(SCREEN_W-160*SCALE, CGRectGetMaxY(bgView.frame)+30*SCALE, 80*SCALE, 50*SCALE) andNormalTitle:@"重开" andSelectedTitle:nil andTitlteColor:[UIColor blackColor] andBackgroundColor:[UIColor orangeColor] andClickedBlock:^(MZButton *sender) {
        [weakSelf requestResetMatch];
    }];
    [self.view addSubview:resetBtn];
    
    //黑子方信息
    MZLabel *blackPlayerTipsLB = [[MZLabel alloc] initWithFrame:CGRectMake(20*SCALE, CGRectGetMaxY(resetBtn.frame)+20*SCALE, 70*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:@"黑子:" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    [self.view addSubview:blackPlayerTipsLB];
    
    MZLabel *blackPlayerLB = [[MZLabel alloc] initWithFrame:CGRectMake(90*SCALE, CGRectGetMaxY(resetBtn.frame)+20*SCALE, SCREEN_W-250*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:self.isWhiteChess?[MZBluetoothManager shareManager].competitor:@"本人" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    blackPlayerLB.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:blackPlayerLB];
    self.blackPlayerLB = blackPlayerLB;
    
    MZLabel *blackChessCountLB = [[MZLabel alloc] initWithFrame:CGRectMake(SCREEN_W-150*SCALE, CGRectGetMaxY(resetBtn.frame)+20*SCALE, 130*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:@"落子数:0" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    [self.view addSubview:blackChessCountLB];
    self.blackChessCountLB = blackChessCountLB;
    
    
    //白子方信息
    MZLabel *whitePlayerTipsLB = [[MZLabel alloc] initWithFrame:CGRectMake(20*SCALE, CGRectGetMaxY(resetBtn.frame)+60*SCALE, 70*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:@"白子:" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    [self.view addSubview:whitePlayerTipsLB];
    
    MZLabel *whitePlayerLB = [[MZLabel alloc] initWithFrame:CGRectMake(90*SCALE, CGRectGetMaxY(resetBtn.frame)+60*SCALE, SCREEN_W-250*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:self.isWhiteChess?@"本人":@"暂无" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    whitePlayerLB.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:whitePlayerLB];
    self.whitePlayerLB = whitePlayerLB;
    
    MZLabel *whiteChessCountLB = [[MZLabel alloc] initWithFrame:CGRectMake(SCREEN_W-150*SCALE, CGRectGetMaxY(resetBtn.frame)+60*SCALE, 130*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:@"落子数:0" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentLeft andFont:[UIFont systemFontOfSize:25*SCALE]];
    [self.view addSubview:whiteChessCountLB];
    self.whiteChessCountLB = whiteChessCountLB;

    
    //落子方
    self.resultLB = [[MZLabel alloc] initWithFrame:CGRectMake(30*SCALE, CGRectGetMaxY(resetBtn.frame)+100*SCALE, SCREEN_W-60*SCALE, 30*SCALE) andbackgroundColor:[UIColor clearColor] andText:@"对局结果：该黑子落子" andTextColor:[UIColor blackColor] andTextAlignment:NSTextAlignmentCenter andFont:[UIFont systemFontOfSize:25*SCALE]];
    [self.view addSubview:self.resultLB];
    
    //开启图像上下文
    UIGraphicsBeginImageContext(CGSizeMake(SCREEN_W-60, SCREEN_W-60));
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 0.8f);
    //画16条竖线
    for (int i=0; i<16; i++) {
        CGContextMoveToPoint(ctx, (SCREEN_W-60)/15.0*i, 0);
        CGContextAddLineToPoint(ctx, (SCREEN_W-60)/15.0*i, SCREEN_W-60);
    }
    
    //画16条横线
    for (int i=0; i<16; i++) {
        CGContextMoveToPoint(ctx, 0, (SCREEN_W-60)/15.0*i);
        CGContextAddLineToPoint(ctx, SCREEN_W-60, (SCREEN_W-60)/15.0*i);
    }
    
    CGContextStrokePath(ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *chessView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, SCREEN_W-60, SCREEN_W-60)];
    chessView.image = image;
    [bgView addSubview:chessView];
    chessView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationChess:)];
    [chessView addGestureRecognizer:tap];
    self.chessView = chessView;
    
    UIGraphicsEndImageContext();
}

//点击棋盘落子
- (void)locationChess:(UITapGestureRecognizer *)tap {
    if ([[MZBluetoothManager shareManager] isCentral]&&!self.hasFriendJoined) {
        [MBProgressHUD showError:@"还未有对手加入游戏，暂不能开始游戏"];
        return;
    }
    if (self.isFinished) {
        [MBProgressHUD showError:@"对局已结束，请重开"];
        return;
    }
    if (!self.isMeStep) {
        [MBProgressHUD showError:@"该对手落子"];
        return;
    }
    CGPoint point = [tap locationInView:tap.view];
    //计算下子的行列号
    NSInteger xPoint = point.x/((SCREEN_W-60)/15.0)+0.5;
    NSInteger yPoint = point.y/((SCREEN_W-60)/15.0)+0.5;
    [self updateChessViewWithChessColor:self.isWhiteChess?[UIColor whiteColor]:[UIColor blackColor] xpoint:xPoint yPoint:yPoint writeData:YES];
}

//点击棋盘或收到对手的落子，更新UI
- (void)updateChessViewWithChessColor:(UIColor *)chessColor xpoint:(NSInteger)xPoint yPoint:(NSInteger)yPoint writeData:(BOOL)writeData{
    if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)xPoint,(long)yPoint]]) {
        return;
    }
    [self.chessDic setObject:chessColor forKey:[NSString stringWithFormat:@"%ld-%ld",(long)xPoint,(long)yPoint]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20*SCALE, 20*SCALE)];
    view.backgroundColor = chessColor;
    view.layer.cornerRadius = 10*SCALE;
    view.layer.masksToBounds = YES;
    view.center = CGPointMake(xPoint*((SCREEN_W-60)/15.0), yPoint*((SCREEN_W-60)/15.0));
    [self.chessView addSubview:view];
    
    self.lastKey = [NSString stringWithFormat:@"%ld-%ld",(long)xPoint,(long)yPoint];
    self.lastView = view;
    
    //判断颜色
    if (CGColorEqualToColor(chessColor.CGColor, [UIColor whiteColor].CGColor)) {
        if ([self checkResultWithXPoint:xPoint yPoint:yPoint chessColor:[UIColor whiteColor]]) {
            [MBProgressHUD showError:@"白子方胜利"];
            self.isFinished = YES;
        }
    } else {
        if ([self checkResultWithXPoint:xPoint yPoint:yPoint chessColor:[UIColor blackColor]]) {
            [MBProgressHUD showError:@"黑子方胜利"];
            self.isFinished = YES;
        }
    }
    if (writeData) {
        self.isMeStep = NO;
        [[MZBluetoothManager shareManager] writeData:[NSString stringWithFormat:@"%d-%ld-%ld",self.isWhiteChess?1:0,xPoint,yPoint]];
    }
    
    [self updatePlayerImformation];
}

- (void)updatePlayerImformation {
    NSInteger count = self.chessDic.allKeys.count;
    if (count % 2 == 0) {
        self.blackPlayerLB.text = self.isWhiteChess?[MZBluetoothManager shareManager].competitor:@"本人";
        self.blackChessCountLB.text = [NSString stringWithFormat:@"落子数:%ld",count/2];
        self.whitePlayerLB.text = self.isWhiteChess?@"本人":[MZBluetoothManager shareManager].competitor;
        self.whiteChessCountLB.text = [NSString stringWithFormat:@"落子数:%ld",count/2];
        self.resultLB.text = [NSString stringWithFormat:@"对局结果：%@",self.isFinished?@"白子胜":@"该黑子落子"];
    } else {
        self.blackPlayerLB.text = self.isWhiteChess?[MZBluetoothManager shareManager].competitor:@"本人";
        self.blackChessCountLB.text = [NSString stringWithFormat:@"落子数:%ld",count/2+1];
        self.whitePlayerLB.text = self.isWhiteChess?@"本人":[MZBluetoothManager shareManager].competitor;
        self.whiteChessCountLB.text = [NSString stringWithFormat:@"落子数:%ld",count/2];
        self.resultLB.text = [NSString stringWithFormat:@"对局结果：%@",self.isFinished?@"黑子胜":@"该白子落子"];
    }
    
}

//是否有玩家胜利
- (BOOL)checkResultWithXPoint:(NSInteger)xpoint yPoint:(NSInteger)yPoint chessColor:(UIColor*)chessColor {
    if (self.chessDic.allKeys.count<8) {
        return NO;
    }
    
    //水平遍历
    int count = 1;
    //向前遍历
    for (NSInteger i=xpoint-1; i>=0; i--) {
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)yPoint]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)yPoint]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    //向后遍历
    for (NSInteger i=xpoint+1; i<=15; i++) {
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)yPoint]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)yPoint]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    if (count>=5) {
        return YES;
    }
    
    //垂直遍历
    count = 1;
    //向上遍历
    for (NSInteger i=yPoint-1; i>=0; i--) {
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)xpoint,(long)i]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)xpoint,(long)i]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    //向下遍历
    for (NSInteger i=yPoint+1; i<=15; i++) {
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)xpoint,(long)i]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)xpoint,(long)i]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    if (count>=5) {
        return YES;
    }

    //右下遍历
    count = 1;
    NSInteger j = yPoint;
    //左上遍历
    for (NSInteger i=xpoint-1; i>=0; i--) {
        j--;
        if (j<0) {
            break;
        }
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    //右下遍历
    j = yPoint;
    for (NSInteger i=xpoint+1; i<=15; i++) {
        j++;
        if (j>15) {
            break;
        }
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    if (count>=5) {
        return YES;
    }

    //左下遍历
    count = 1;
    j = yPoint;
    //左下遍历
    for (NSInteger i=xpoint-1; i>=0; i--) {
        j++;
        if (j>15) {
            break;
        }
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    //右上遍历
    j = yPoint;
    for (NSInteger i=xpoint+1; i<=15; i++) {
        j--;
        if (j<0) {
            break;
        }
        if ([self.chessDic.allKeys containsObject:[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]] && self.chessDic[[NSString stringWithFormat:@"%ld-%ld",(long)i,(long)j]]==chessColor) {
            count++;
        } else {
            break;
        }
    }
    if (count>=5) {
        return YES;
    }

    return NO;
}

//发起悔棋的请求
- (void)backLastStepRequest {
    if (self.chessDic.allKeys.count == 0) {
        [MBProgressHUD showError:@"请先下子"];
        return;
    }
    
    if (self.isFinished) {
        [MBProgressHUD showError:@"该局输赢已定，不能悔棋"];
        return;
    }
    
    if (!self.lastKey || !self.lastView) {
        [MBProgressHUD showError:@"一次只能悔棋一步"];
        return;
    }
    if (self.isMeStep) {
        [MBProgressHUD showError:@"您正处于落子方，不能悔棋"];
    } else {
        [[MZBluetoothManager shareManager] writeData:@"backLastStep"];
        [MBProgressHUD showSuccess:@"悔棋请求已发送,请等待对手确认"];
    }
}

//确认请求，更新UI
- (void)backLastStep {
    [self.lastView removeFromSuperview];
    [self.chessDic removeObjectForKey:self.lastKey];
    self.lastKey = nil;
    self.lastView = nil;
    [self updatePlayerImformation];
}

//发起重开游戏的请求
- (void)requestResetMatch {
    if (!self.isFinished) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该局输赢未定，请问您是否确认重开？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[MZBluetoothManager shareManager] writeData:@"resetMatch"];
            [MBProgressHUD showSuccess:@"已发送重开请求给对手，请等待对手确认"];
        }];
        [alert addAction:okAction];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[MZBluetoothManager shareManager] writeData:@"resetMatch"];
        [MBProgressHUD showSuccess:@"已发送重开请求给对手，请等待对手确认"];
    }
}

//确认重开游戏，更新UI
- (void)resetMatch {
    self.isFinished = NO;
    [self.chessDic removeAllObjects];
    self.lastKey = nil;
    self.lastView = nil;
    for (UIView *subView in self.chessView.subviews) {
        [subView removeFromSuperview];
    }
    [self updatePlayerImformation];
}

#pragma mark -MZBluetoothManagerDelegate
//获取对手发送的指令
- (void)getData:(NSString *)data {
    if ([data isEqualToString:@"backLastStep"]) {
        //收到对手请求悔棋指令
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"对手请求悔棋，是否同意？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self backLastStep];
            self.isMeStep = NO;
            [[MZBluetoothManager shareManager] writeData:@"backLastStepYes"];
            [MBProgressHUD showSuccess:@"您已同意悔棋，该对手落子"];
        }];
        [alert addAction:okAction];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"不同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[MZBluetoothManager shareManager] writeData:@"backLastStepNo"];
            [MBProgressHUD showSuccess:@"您不同意悔棋，请继续落子"];
        }];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else if ([data isEqualToString:@"backLastStepYes"]) {
        //收到对手同意悔棋的指令
        [MBProgressHUD showSuccess:@"对手已同意悔棋，请您落子"];
        [self backLastStep];
        self.isMeStep = YES;
        return;
    } else if ([data isEqualToString:@"backLastStepNo"]) {
        //收到对手不同意悔棋的指令
        [MBProgressHUD showSuccess:@"呜～,对手不同意悔棋，依旧由对手落子"];
        return;
    } else if ([data isEqualToString:@"resetMatch"]) {
        //收到对手请求重开游戏的指令
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"对手请求重开游戏，请问您同意吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.isWhiteChess = !self.isWhiteChess;
            self.isMeStep = !self.isWhiteChess;
            [self resetMatch];
            [[MZBluetoothManager shareManager] writeData:@"resetMatchYes"];
            [MBProgressHUD showSuccess:@"游戏已重开，双方交换棋色，由黑子先落子"];
        }];
        [alert addAction:okAction];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"不同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[MZBluetoothManager shareManager] writeData:@"resetMatchNo"];
        }];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else if ([data isEqualToString:@"resetMatchYes"]) {
        //收到对手同意重开游戏的指令
        self.isWhiteChess = !self.isWhiteChess;
        self.isMeStep = !self.isWhiteChess;
        [self resetMatch];
        [MBProgressHUD showSuccess:@"对手已同意游戏重开，双方交换棋色，由黑子先落子"];
        return;
    } else if ([data isEqualToString:@"resetMatchNo"]) {
        //收到对手不同意重开游戏的指令
        [MBProgressHUD showSuccess:@"对手不同意重开游戏，请继续游戏"];
        return;
    } else if ([data hasPrefix:@"beginGame"]) {
        //收到对手进入房间的指令
        [[MZBluetoothManager shareManager] setCompetitor:[data substringFromIndex:9]];
        [self updatePlayerImformation];
        self.hasFriendJoined = YES;
        [MBProgressHUD showSuccess:@"对手已进入房间，游戏开始，请黑子先落子"];
        return;
    } else if ([data isEqualToString:@"leaveRoom"]) {
        //收到对手离开房间的指令
        self.hasFriendJoined = NO;
        [MBProgressHUD showError:@"对手已离开房间，本局游戏结束"];
        if (![[MZBluetoothManager shareManager] isCentral]) {
            [[MZBluetoothManager shareManager] disConnect];
            self.view.userInteractionEnabled = NO;
            [self performSelector:@selector(back) withObject:nil afterDelay:2.0f];
        } else {
            self.isWhiteChess = NO;
            self.isMeStep = YES;
            [self resetMatch];
            [[MZBluetoothManager shareManager] startAdvitise];
        }
        return;
    }
    self.isMeStep = YES;
    NSArray *arr = [data componentsSeparatedByString:@"-"];
    [self updateChessViewWithChessColor:[arr[0] isEqualToString:@"1"]?[UIColor whiteColor]:[UIColor blackColor] xpoint:[arr[1] integerValue] yPoint:[arr[2] integerValue] writeData:NO];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
