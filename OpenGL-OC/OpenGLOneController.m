//
//  OpenGLOneController.m
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/7.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import "OpenGLOneController.h"
#import "MyGLView.h"
@interface OpenGLOneController ()

@end

@implementation OpenGLOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *myView = [[MyGLView alloc] init];
    myView.frame = self.view.bounds;
    [self.view addSubview:myView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
