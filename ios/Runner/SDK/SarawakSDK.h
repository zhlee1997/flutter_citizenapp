//
//  SarawakSDK.h
//  SarawakSDK
//
//  Created by Shirley on 12/1/18.
//  Copyright © 2018 卜雪妮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SarawakSDK : NSObject

@property(nonatomic,strong) NSString * urlScheme;

+(instancetype)defaultService;

-(void)callSPay:(NSString *)Str;

@end
