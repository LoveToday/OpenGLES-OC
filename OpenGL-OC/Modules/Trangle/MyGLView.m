//
//  MyGLView.m
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/7.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import "MyGLView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESUtils.h"
@interface MyGLView()
{
    GLuint myColorRenderBuffer;
    GLuint myColorFrameBuffer;
    GLuint myProgram;
    
    GLuint positionSlot;
    GLuint colorSlot;
    EAGLContext *myContext;
    
}
@end

@implementation MyGLView
- (instancetype)init
{
    self = [super init];
    if (self) {
        myColorRenderBuffer = 0;
        myColorFrameBuffer = 0;
        myProgram = 0;
        positionSlot = 0;
        colorSlot = 0;
    }
    return self;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /// 第一步， 处理显示层
    [self setUpLayer];
    /// 设置当前上下文
    [self setUpContext];
    /// 首先先要销毁之前的内存
    [self destoryRenderAndFrameBuffer];
    /// 告诉GPU绘制的内存情况
    [self setUpBuffer];
    /// 启动一个程序 此程序用于加载着色器等
    [self setupProgram];
    [self render];
}


- (void)setUpLayer{
    CAEAGLLayer *myLayer = (CAEAGLLayer *)self.layer;
    /// 默认是透明的，设置为不透明
    myLayer.opaque = YES;
    // 设置draw属性
    myLayer.drawableProperties = @{
                                   kEAGLDrawablePropertyRetainedBacking: @NO,
                                   kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                   };
    
}

-(void)setUpContext
{
    /// 制定opengl的版本
    myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (myContext == nil) {
        NSLog(@"初始化失败");
        return;
    }
    /// 设置成当前的上下文
    if (![EAGLContext setCurrentContext:myContext]) {
        NSLog(@"context设置失败");
        return;
    }
}

- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &myColorFrameBuffer);
    myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &myColorRenderBuffer);
    myColorRenderBuffer = 0;
}
- (void)setUpBuffer{
    //// 1. 创建颜色缓冲对象
    GLuint buffer = 0;
    ///  2. 申请一个缓冲区标记
    glGenRenderbuffers(1, &buffer);
    /// 3.
    myColorRenderBuffer = buffer;
    ///  4. 将缓冲区绑定到指定的空间中，把myColorRenderBuffer绑定在OpenGL ES的渲染缓存GL_RENDERBUFFER上
    glBindRenderbuffer(GL_RENDERBUFFER, myColorRenderBuffer);
    /// 将可绘制对象的存储绑定到OpenGL ES renderbuffer对象
    // target OpenGL ES绑定点用于当前绑定的renderbuffer。该参数的值必须是GL_RENDERBUFFER
    /// drawable 管理renderbuffer的数据存储的对象。在iOS中，此参数的值必须是一个 CAEAGLLayer 对象
    ///赋值
    [myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    //// 下面创建帧缓冲对象并绑定
    // 2、申请一个缓存区标记
    glGenFramebuffers(1, &buffer);
    myColorFrameBuffer = buffer;
    // 将缓冲区绑定到指定的空间中
    glBindFramebuffer(GL_FRAMEBUFFER, myColorFrameBuffer);
    //// 将颜色渲染内存 配到 GL_COLOR_ATTACHMENT0 配置点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, myColorRenderBuffer);
}
/// 设置程序
- (void)setupProgram {
    myProgram = [GLESUtils loadProgram:@"shaderv.glsl" fragShader:@"shaderf.glsl"];
    if (myProgram == 0) {
        return;
    }
    glUseProgram(myProgram);

    positionSlot = glGetAttribLocation(myProgram, "vPosition");
    colorSlot = glGetAttribLocation(myProgram, "a_Color");
    
}

- (void)render
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, (GLsizei)self.frame.size.width, (GLsizei)self.frame.size.height);
    /// 顶点的坐标系统是在正中心
    GLfloat vertices[] = {
      0.0f, 0.5f, 0.0f,
      -0.5f, -0.5f, 0.0f,
      0.5f, -0.5f, 0.0f
    };
    GLfloat colors[] = {
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
    };
    /// 加载顶点数据
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 0, &vertices);
    glEnableVertexAttribArray(positionSlot);
    
    /// 加载颜色数据
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, 0, &colors);
    glEnableVertexAttribArray(colorSlot);
    
    /// 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
    [myContext presentRenderbuffer:GL_RENDERBUFFER];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
