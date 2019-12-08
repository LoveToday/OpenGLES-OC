//
//  GLESUtils.m
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/7.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLESUtils.h"

@implementation GLESUtils
+ (GLuint)loadProgram:(NSString *)verShaderFileName
           fragShader:(NSString *)fragShaderFileName
{
    GLuint vertextShader = [GLESUtils loadShaderFile:GL_VERTEX_SHADER file:verShaderFileName];
    GLuint fragmentShader = [GLESUtils loadShaderFile:GL_FRAGMENT_SHADER file:fragShaderFileName];
    if (fragmentShader == 0) {
        glDeleteShader(vertextShader);
        return 0;
    }
    
    GLuint programHandel = glCreateProgram();
    if (programHandel == 0) {
        return 0;
    }
    
    /// 将着色器附加到程序上
    glAttachShader(programHandel, vertextShader);
    glAttachShader(programHandel, fragmentShader);
    
    /// 链接着色器程序
    glLinkProgram(programHandel);
    /// 获取链接状态
    GLint linkStatus = 0;
    glGetProgramiv(programHandel, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        //获取失败信息
        GLchar message[512];
        //来检查是否有error，并输出信息
        /*
         作用:连接着色器程序也可能出现错误，我们需要进行查询，获取错误日志信息
         参数1: program 着色器程序标识
         参数2: bufsize 最大日志长度
         参数3: length 返回日志信息的长度
         参数4：infoLog 保存在缓冲区中
         */
        glGetProgramInfoLog(programHandel, sizeof(message), 0, &message[0]);
        
        //将C语言字符串转换成OC字符串
        NSString * messageStr = [NSString stringWithUTF8String:message];
        
        NSLog(@"Program Link Error:%@",messageStr);
        
        return 0;
    }
    // 释放资源
    glDeleteShader(vertextShader);
    glDeleteShader(fragmentShader);
    return programHandel;
}

+ (GLuint)loadShaderFile:(GLenum)type
                    file:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (!path) {
        return 0;
    }
    NSError *error;
    NSString *shaderString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return [GLESUtils loadShaderString:type shader:shaderString];
}

+ (GLuint)loadShaderString:(GLenum)type
                    shader:(NSString *)shaderString
{
    /// 创建着色器对象
    GLuint shaderHandel = glCreateShader(type);
    //GLint shaderStringLength = sizeof(shaderString);
    //2、将OC字符串->C语言字符串
    const GLchar * source = (GLchar *)[shaderString UTF8String];
    //char shaderCString;

    /// 把着色器源码添加到着色器对象上
    glShaderSource(shaderHandel, 1, &source, NULL);
    ///编译着色器
    glCompileShader(shaderHandel);
    
    // 编译是否成功 GL_FALSE GL_TRUE
    GLint compileStatus = 0;
    /// 获取编译状态
    glGetShaderiv(shaderHandel, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLsizei infoLength = 0;
        GLsizei bufferLength = 1024;
        glGetShaderiv(shaderHandel, GL_INFO_LOG_LENGTH, &infoLength);
        NSArray *info = [NSArray arrayWithObjects:0 count:bufferLength];
        GLsizei actualLength = 0;
        
        
        /// 获取错误消息
        //glGetShaderInfoLog(shaderHandel, bufferLength, &actualLength, info);
        
        return 0;
    }
    return shaderHandel;
}

+ (GLuint)createVBO:(GLenum)target
              usage:(GLenum)usage
            datSize:(NSInteger)datSize
               data:(const GLvoid*)data{
    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, datSize, data, usage);
    return vbo;
}

+ (GLuint)createTexture2D:(NSString *)fileName{
    GLuint texture = 0;
    // 将图片转换成可操作位图
    CGImageRef spriteImage = [[UIImage imageNamed:fileName] CGImage];
    if (spriteImage == nil) {
        NSLog(@"failed to load image %@", fileName);
        return 0;
    }
    //获取横向的像素点的个数
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    size_t bitsPerComponent = CHAR_BIT;
    //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    //指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(spriteImage);
    if (alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaOnly) {
        alphaInfo = kCGImageAlphaNoneSkipFirst;
    } else if (alphaInfo == kCGImageAlphaFirst) {
        alphaInfo = kCGImageAlphaPremultipliedFirst;
    } else if (alphaInfo == kCGImageAlphaLast) {
        alphaInfo = kCGImageAlphaPremultipliedLast;
    }
    bitmapInfo |= alphaInfo;
    //NSData *spriteData =
    //计算整张图占用的字节数
    NSInteger bitmapByteCount = (bytesPerRow * height);
    //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    void *spriteData = malloc(bitmapByteCount);
    // 创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, bitmapInfo);
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    CGColorSpaceRelease(colorSpaceDeviceRGBRef);
    /// 在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    /// 4. 绑定纹理到默认的纹理ID
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    
    return texture;

}

@end
