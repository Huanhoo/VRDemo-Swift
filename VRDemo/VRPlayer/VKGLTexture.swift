//
//  VKGLTexture.swift
//  VRDemo
//
//  Created by huhuan on 2016/12/5.
//  Copyright © 2016年 Huanhoo. All rights reserved.
//

import UIKit

class VKGLTexture: NSObject {
    
    var lumaTexture: CVOpenGLESTexture?
    var chromaTexture: CVOpenGLESTexture?
    var videoTextureCache: CVOpenGLESTextureCache?
    
    var glContext: EAGLContext?
    
    init(context: EAGLContext) {
        super.init()
        glContext = context
        configureVideoCache()
    }
    
    func configureVideoCache() {
        if videoTextureCache == nil {
            
            let result: CVReturn  = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, glContext!, nil, &videoTextureCache);
            if result != noErr {
                print("create CVOpenGLESTextureCacheCreate failure")
            }
            
        }
    
    }
    
    func refreshTextureWithPixelBuffer(pixelBuffer: CVPixelBuffer?) {
    
        if pixelBuffer == nil { return }
        
        
        var result: CVReturn ;
        
        var textureWidth: GLsizei  = GLsizei(CVPixelBufferGetWidth(pixelBuffer!))
        var textureHeight: GLsizei  = GLsizei(CVPixelBufferGetHeight(pixelBuffer!))
        
        if videoTextureCache == nil {
            
            print("no video texture cache");
            return;
            
        }
        
        cleanTextures()
        
        glActiveTexture(GLenum(GL_TEXTURE0));
        result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                              videoTextureCache!,
                                                              pixelBuffer!,
                                                              nil,
                                                              GLenum(GL_TEXTURE_2D),
                                                              GL_RED_EXT,
                                                              textureWidth,
                                                              textureHeight,
                                                              GLenum(GL_RED_EXT),
                                                              GLenum(GL_UNSIGNED_BYTE),
                                                              0,
                                                              &lumaTexture);
        if result != 0 {
            print("create CVOpenGLESTextureCacheCreateTextureFromImage failure 1 %d", result);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture!), CVOpenGLESTextureGetName(lumaTexture!));
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE));
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE));
        
        // UV-plane.
        glActiveTexture(GLenum(GL_TEXTURE1));
        result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                              videoTextureCache!,
                                                              pixelBuffer!,
                                                              nil,
                                                              GLenum(GL_TEXTURE_2D),
                                                              GL_RG_EXT,
                                                              textureWidth/2,
                                                              textureHeight/2,
                                                              GLenum(GL_RG_EXT),
                                                              GLenum(GL_UNSIGNED_BYTE),
                                                              1,
                                                              &chromaTexture);
        if result != 0 {
            print("create CVOpenGLESTextureCacheCreateTextureFromImage failure 2 %d", result);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture!), CVOpenGLESTextureGetName(chromaTexture!));
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE));
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE));
        
        
    }
    
    deinit {
        cleanTextures()
        clearVideoCache()
    }
    
    func clearVideoCache() {
        videoTextureCache = nil
    }
    
    func cleanTextures() {
        
        if self.lumaTexture != nil {
            self.lumaTexture = nil;
        }
        
        if self.chromaTexture != nil {
            self.chromaTexture = nil;
        }
        
        CVOpenGLESTextureCacheFlush(videoTextureCache!, 0);
        
    }
    
}
