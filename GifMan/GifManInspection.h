//
//  GifManInspection.h
//  GifMan
//
//  Created by Tom Arnfeld on 05/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassDisplay.h"

//
// Print out the methods (including types) for a given class
//
GIFMAN_EXPORT void GMPrintMethodsOfClass(Class aClass);

//
// Print out the iVars of a class
//
GIFMAN_EXPORT void GMPrintInstanceVariablesOfClass(Class aClass);

//
// Print out the properties of a class
//
GIFMAN_EXPORT void GMPrintPropertiesOfClass(Class aClass);

//
// Print out the protocols a class conforms to
//
GIFMAN_EXPORT void GMPrintProtocolsOfClass(Class aClass);

//
// Print out the protocols a protocol conforms to
//
GIFMAN_EXPORT void GMPrintProtocolsOfProtocol(Protocol *aProtocol);

//
// Print all classes
//
GIFMAN_EXPORT void GMPrintClasses();

//
// List all classes
//
GIFMAN_EXPORT NSArray *GMListClasses();

//
// Render out a class
//
GIFMAN_EXPORT NSString *GMRenderClass(Class aClass);

//
// Dump all runtime class headers to a folder
//
GIFMAN_EXPORT void GMDumpHeaders(NSString *folderPath);
