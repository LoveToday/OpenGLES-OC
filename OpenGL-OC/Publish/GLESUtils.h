//
//  GLESUtils.h
//  OpenGL-OC
//
//  Created by 陈江林 on 2019/12/7.
//  Copyright © 2019 陈江林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLESUtils : NSObject
+ (GLuint)loadProgram:(NSString *)verShaderFileName
           fragShader:(NSString *)fragShaderFileName;
+ (GLuint)createVBO:(GLenum)target
              usage:(GLenum)usage
            datSize:(NSInteger)datSize
               data:(const GLvoid*)data;
+ (GLuint)createTexture2D:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
