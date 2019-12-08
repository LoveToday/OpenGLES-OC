//
//  ViewController.m
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/7.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLOneController.h"
#import "OpenGLTwoController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"三角形绘制";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"纹理";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        /// 三角形绘制
        OpenGLOneController *one = [[OpenGLOneController alloc] init];
        [self.navigationController pushViewController:one animated:YES];
    }else if (indexPath.row == 1){
        /// 纹理
        OpenGLTwoController *two = [[OpenGLTwoController alloc] init];
        [self.navigationController pushViewController:two animated:YES];
    }
}


@end
