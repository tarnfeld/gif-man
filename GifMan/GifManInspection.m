//
//  GifManInspection.m
//  GifMan
//
//  Created by Tom Arnfeld on 05/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManInspection.h"

#import <objc/runtime.h>
#import <objc/message.h>

void GMPrintMethodsOfClass(Class aClass)
{
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    
    for (int i = 0; i < methodCount; i++) {
        char buffer[256];
        
        SEL name = method_getName(methods[i]);
        NSLog(@"Method: %@", NSStringFromSelector(name));
        
        char *returnType = method_copyReturnType(methods[i]);
        NSLog(@"  The return type is %s", returnType);
        free(returnType);
        
        unsigned int numberOfArguments = method_getNumberOfArguments(methods[i]);
        for (int j = 0; j < numberOfArguments; j++) {
            method_getArgumentType(methods[i], j, buffer, 256);
            NSLog(@"    The type of argument %d is %s", j, buffer);
        }
    }
    
    free(methods);
}

void GMPrintInstanceVariablesOfClass(Class aClass)
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList(aClass, &count);
    
    for (unsigned int i = 0; i < count; ++i) {
        NSLog(@"%@::%s", aClass, ivar_getName(ivars[i]));
    }
    
    free(ivars);
}

void GMPrintPropertiesOfClass(Class aClass)
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        
        const char *name = property_getName(properties[i]);
        NSLog(@"%s", name);
    }
    
    free(properties);
}

void GMPrintProtocolsOfClass(Class aClass)
{
    unsigned int protocolCount = 0;
    Protocol **protocols = class_copyProtocolList(aClass, &protocolCount);
    
    for (int i = 0; i < protocolCount; i++) {
        
        const char *name = protocol_getName(protocols[i]);
        NSLog(@"%s", name);
    }
    
    free(protocols);
}
