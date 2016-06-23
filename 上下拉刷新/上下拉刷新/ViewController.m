//
//  ViewController.m
//  上下拉刷新
//
//  Created by piaojin on 16/6/23.
//  Copyright (c) 2016年 piaojin. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"

#define LOADDING_HEIGHT 36.0//加载更多动画的高度
#define LOADMORE_START  65.0//上拉多少触发加载更多

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL loadding;//是否正在加载更多
@property (nonatomic, strong) UIView *loadMoreView;//加载更多动画视图

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"CELL";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ID];
        cell.backgroundColor = [UIColor orangeColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 16;
}

/**
 *  基本上就是在拖动结束的回调方法里面检查 scrollview的contentOffset.y值 超过scrollView实际的下边界的大小，如果超过了一个指定的值就触发上拉刷新
 scrollview的contentOffset.y 当前的offsetY
 scrollView.contentSize.height - scrollView.frame.size.height 实际的下边界Y
 
 if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + x) //x是触发操作的阀值
 {
 //触发上拉刷新
 }
 用fmaxf来取与0比较后较大值的原因是，当scrollView内容为空时scrollView.contentSize.height可能是0
 当然还需要判断当前是否正在加载了
 *
 *  @param scrollView
 */
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!self.loadding){
        if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + LOADMORE_START) //x是触发操作的阀值
        {
            //触发上拉刷新
            NSLog(@"上拉加载更多......");
            [self startLoadMoreAnimating];
        }
    }
}

-(void)startLoadMoreAnimating{
    [UIView animateWithDuration:0.3 animations:^{
        //使得加载更多的动画的空间腾出来
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, LOADDING_HEIGHT, 0);
        [self.tableView addSubview:self.loadMoreView];
        [self startLoadMore];
    }];
}

-(void)endLoadMoreAnimating{
    if(!self.loadding){
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsZero;
            [self.loadMoreView removeFromSuperview];
        }];
    }
}

/**
 *  这边可以设置自定义代理，发出加载更多回调
 */
-(void)startLoadMore{
    self.loadding = YES;
    //加载更多......
    [self didLoadding];
}

/**
 *  加载完毕,刷新表格
 */
-(void)endLoadMore{
    self.loadding = NO;
    [self endLoadMoreAnimating];
    //刷新表格......
}

/**
 *  模拟加载中
 */
-(void)didLoadding{
    [self performSelector:@selector(endLoadMore) withObject:nil afterDelay:2.0];
}

-(UIView *)loadMoreView{
    if(!_loadMoreView){
        _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.contentSize.height, self.tableView.frame.size.width, LOADDING_HEIGHT)];
        _loadMoreView.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView *loaddingAnimationView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [UIView setAnimationsEnabled:NO];
        loaddingAnimationView.center = CGPointMake(_loadMoreView.frame.size.width / 2.0, _loadMoreView.frame.size.height / 2.0);
        [_loadMoreView addSubview:loaddingAnimationView];
        [loaddingAnimationView startAnimating];
        [UIView setAnimationsEnabled:YES];
    }
    return _loadMoreView;
}

-(void)dealloc{
    [_loadMoreView removeFromSuperview];
}

@end
