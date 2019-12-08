//
//  TextureGLView.m
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/8.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import "TextureGLView.h"
#import "GLESUtils.h"

@interface TextureGLView()
{
    CAEAGLLayer *myLayer;
    EAGLContext *myContext;
    GLuint myColorRenderBuffer;
    GLuint myColorFrameBuffer;
    GLuint myProgram;
    
    GLuint position_loc;
    GLuint texture_loc;
    int32_t tex1_loc;
//    int32_t tex2_loc;
    
    NSInteger vertCount;
    GLuint vbo;
    
    GLuint text1;
//    GLuint text2;
}
@end


@implementation TextureGLView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /// 设置显示层
        [self setUpLayer];
        /// 设置上下文
        [self setUpContext];
        [self setUpProgram];
        [self setupVBO];
        [self setUpTexture];
    }
    return self;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [EAGLContext setCurrentContext:myContext];
    
    [self destoryRenderAndFrameBuffer];
    [self setUpBuffer];
    [self render];
    
}
/// 设置layer
- (void)setUpLayer{
    myLayer = (CAEAGLLayer *)self.layer;
    myLayer.opaque = YES;
    myLayer.drawableProperties = @{
                                   kEAGLDrawablePropertyRetainedBacking: @NO,
                                   kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                   };
}
- (void)setUpContext{
    myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (myContext == nil) {
        NSLog(@"初始化上下文失败");
        return;
    }
    if (![EAGLContext setCurrentContext:myContext]) {
        NSLog(@"设置上下文失败");
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
- (void)setUpProgram{
    myProgram = [GLESUtils loadProgram:@"texture_shaderv.glsl" fragShader:@"texture_shaderf.glsl"];
    if (myProgram == 0) {
        return;
    }
    glUseProgram(myProgram);
    
    position_loc = glGetAttribLocation(myProgram, "in_position");
    texture_loc = glGetAttribLocation(myProgram, "in_tex_coord");
    
    tex1_loc = glGetUniformLocation(myProgram, "tex1");
//    tex2_loc = glGetUniformLocation(myProgram, "tex2");
    
    
}

- (void)setupVBO {
    GLfloat vertices[] = {
        0.5f, 0.5f, 1.0f, 0.0f, // 右上
        0.5f, -0.5f, 1.0f, 1.0f, // 右下
        -0.5f, -0.5f, 0.0f, 1.0f, // 左下
        -0.5f, -0.5f, 0.0f, 1.0f, // 左下
        -0.5f, 0.5f, 0.0f, 0.0f,  // 左上
        0.5f, 0.5f, 1.0f, 0.0f    // 右上
    };
    vertCount = 24;
    
    vbo = [GLESUtils createVBO:GL_ARRAY_BUFFER
                         usage:GL_STATIC_DRAW
                       datSize:sizeof(vertices)
                          data:vertices];
    glEnableVertexAttribArray(position_loc);
    glVertexAttribPointer(position_loc, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (void *)0);
    
    glEnableVertexAttribArray(texture_loc);
    glVertexAttribPointer(texture_loc, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (void *)(sizeof(GLfloat) * 2));
    
    
}

- (void)setUpTexture{
    text1 = [GLESUtils createTexture2D:@"dungeon_01.jpg"];
//    text2 = [GLESUtils createTexture2D:@"mixture.jpg"];
}

- (void)render{
    glClearColor(0.0, 1.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    
    // 激活纹理单元
    glActiveTexture(GL_TEXTURE0);
    // 绑定纹理到指定纹理单元
    glBindTexture(GL_TEXTURE_2D, text1);
    // 给采样器分配位置值
    glUniform1i(tex1_loc, 0);
    
//    // 激活纹理单元
//    glActiveTexture(GL_TEXTURE1);
//    // 绑定纹理到指定纹理单元
//    glBindTexture(GL_TEXTURE_2D, text2);
//    // 给采样器分配位置值
//    glUniform1i(tex2_loc, 1);
    
    
    
    glDrawArrays(GL_TRIANGLES, 0, (int)vertCount);
    [myContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
