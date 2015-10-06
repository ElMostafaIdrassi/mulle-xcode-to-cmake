/*
 mulle-xcode-settings
 
 $Id: utility-main.m,v 71cb8aaa9ef7 2011/12/21 14:00:39 nat $
 
 Created by Nat! on 06.10.15
 Copyright 2015 Mulle kybernetiK
 
 This file is part of mulle-xcode-settings
 
 mulle-xcode-settings is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 mulle-xcode-settings is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with mulle-xcode-settings.  If not, see <http://www.gnu.org/licenses/>.
 */
#import <Foundation/Foundation.h>

#import "MullePBXArchiver.h"
#import "MullePBXUnarchiver.h"
#import "PBXObject.h"


static void   usage()
{
   fprintf( stderr,
           "usage: mulle-xcode-settings [options] <commands> <file.xcodeproj>\n"
           "\n"
           "Options:\n"
           ""
           "\t-configuration <configuration> : configuration to set\n"
           "\t-target <target>               : target to set\n"
           "\n"
           "Commands:\n"
           "\tset     <key> <value>          : sets key to value\n"
           "\tadd     <key> <value>          : adds value to key\n"
           "\tremove  <key> <value>          : removes value from key\n"
         );
   
   exit( 1);
}


static PBXTarget   *find_target_by_name( PBXProject *root, NSString *name)
{
   NSEnumerator   *rover;
   PBXTarget      *pbxtarget;
   
   rover = [[root targets] objectEnumerator];
   while( pbxtarget = [rover nextObject])
      if( [[pbxtarget name] isEqualToString:name])
         break;
   
   return( pbxtarget);
}

static XCBuildConfiguration  *find_configuration_by_name( PBXObjectWithConfigurationList *root, NSString *name)
{
   NSEnumerator            *rover;
   XCBuildConfiguration    *pbxconfiguration;
   
   rover = [[root buildConfigurations] objectEnumerator];
   while( pbxconfiguration = [rover nextObject])
      if( [[pbxconfiguration name] isEqualToString:name])
         break;
   
   return( pbxconfiguration);
}


enum Command
{
   Set,
   Add,
   Remove
};


static void  fail( NSString *format, ...)
{
   va_list   args;
   
   va_start( args, format);
   NSLogv( format, args);
   va_end( args);
   
   exit( 1);
}


static void   hackit( XCBuildConfiguration *xcconfiguration, enum Command cmd,  NSString *key, NSString *value)
{
   NSMutableDictionary   *settings;
   NSString              *prevValue;
   NSRange               range;
   NSRange               range2;
   
   settings  = [[[xcconfiguration buildSettings] mutableCopy] autorelease];
   prevValue = [settings objectForKey:key];
   range     = [prevValue rangeOfString:value];
   
   switch( cmd)
   {
   case Add    :
      if( range.length != 0)
         return;
         
      if( [prevValue length])
      {
         prevValue = [prevValue stringByAppendingString:@" "];
         value = [prevValue stringByAppendingString:value];
      }
         
   case Set:
      break;
         
   case Remove :
      range2 = [prevValue rangeOfString:[@" " stringByAppendingString:value]];
      if( range2.length)
         range = range2;
      
      value = [prevValue stringByReplacingCharactersInRange:range
                                                 withString:@""];
      break;
   }

   if( [value length])
      [settings setObject:value
                   forKey:key];
   else
      [settings removeObjectForKey:key];
   
   [xcconfiguration setObject:settings
                       forKey:@"buildSettings"];
}


static void   setting_hack( PBXProject *root, enum Command cmd, NSString *key, NSString *value, NSString *configuration, NSString *target)
{
   PBXTarget                        *pbxtarget;
   XCBuildConfiguration             *xcconfiguration;
   PBXObjectWithConfigurationList   *obj;
   NSEnumerator                     *rover;

   obj = root;
   if( target)
   {
      pbxtarget = find_target_by_name( root, target);
      if( ! pbxtarget)
         fail( @"target \"%@\" not found", target);
      obj = pbxtarget;
   }

   if( configuration)
   {
      xcconfiguration = find_configuration_by_name( obj, configuration);
      if( ! xcconfiguration)
         fail( @"configuration \"%@\" not found", configuration);
      hackit( xcconfiguration, cmd, key, value);
      return;
   }

   rover = [[obj buildConfigurations] objectEnumerator];
   while( xcconfiguration = [rover nextObject])
      hackit( xcconfiguration, cmd, key, value);
}


static NSString  *backupPathForPath( NSString *file)
{
   NSString  *ext;
   NSString  *dir;
   NSString  *name;
   
   dir  = [file stringByDeletingLastPathComponent];
   name = [file lastPathComponent];
   ext  = [name pathExtension];
   name = [name stringByDeletingPathExtension];
   name = [name stringByAppendingString:@"~"];
   name = [name stringByAppendingPathExtension:ext];
   file = [dir stringByAppendingPathComponent:name];
   return( file);
}


static void   writeStringToPath( NSString *s, NSString *file)
{
   NSString        *backupFile;
   NSFileManager   *manager;
   NSError         *error;
   
   backupFile = backupPathForPath( file);
   manager    = [NSFileManager defaultManager];
   
   [manager removeItemAtPath:backupFile
                       error:&error];
   if( ! [manager moveItemAtPath:file
                          toPath:backupFile
                           error:&error])
      fail( @"failed to backup %@", file);

   if( ! [s writeToFile:file
             atomically:YES
               encoding:NSUTF8StringEncoding
                  error:&error])
      fail( @"failed to write %@: %@", [error localizedFailureReason]);
}


static int   _main( int argc, const char * argv[])
{
   NSArray         *arguments;
   NSDictionary    *plist;
   NSString        *backupFile;
   NSString        *configuration;
   NSString        *file;
   NSString        *key;
   NSString        *s;
   NSString        *target;
   NSString        *value;
   id              root;
   unsigned int    i, n;
   
   configuration = nil;
   target        = nil;
   
   arguments = [[NSProcessInfo processInfo] arguments];
   n         = [arguments count];
   
   if( [arguments containsObject:@"-version"])
   {
      fprintf( stderr, "v%.1f\n", CURRENT_PROJECT_VERSION);
      return( 0);
   }
   
   file = [arguments lastObject];
   if( ! --n)
      usage();
   
   if( [[file pathExtension] isEqualToString:@"xcodeproj"])
      file = [file stringByAppendingPathComponent:@"project.pbxproj"];
   
   root = [MullePBXUnarchiver unarchiveObjectWithFile:&file];
   if( ! root)
      fail( @"File %@ is not a PBX (Xcode) file", file);
   
   for( i = 1; i < n; i++)
   {
      s = [arguments objectAtIndex:i];
      
      // options
      if( [s isEqualToString:@"-configuration"])
      {
         if( ++i >= n)
            usage();
         
         configuration = [arguments objectAtIndex:i];
         continue;
      }

      if( [s isEqualToString:@"-target"])
      {
         if( ++i >= n)
            usage();
         
         target = [arguments objectAtIndex:i];
         continue;
      }

      if( ++i >= n - 1)
         usage();
      
      key   = [arguments objectAtIndex:i];
      value = [arguments objectAtIndex:++i];

      // commands
      if( [s isEqualToString:@"set"])
      {
         setting_hack( root, Set, key, value, configuration, target);
         continue;
      }
      
      if( [s isEqualToString:@"add"])
      {
         setting_hack( root, Add, key, value, configuration, target);
         continue;
      }
      
      if( [s isEqualToString:@"remove"])
      {
         setting_hack( root, Remove, key, value, configuration, target);
         continue;
      }
      
      NSLog( @"unknown command %@", s);
      usage();
   }
   
   plist = [MullePBXArchiver archivedPropertyListWithRootObject:root];
   s     = [NSString stringWithFormat:@"// !$*UTF8*$!\n%@", [plist description]];

   writeStringToPath( s, file);
   
   return( 0);
}


int   main( int argc, const char * argv[])
{
   NSAutoreleasePool   *pool;
   int                 rval;
   
   pool = [NSAutoreleasePool new];
   rval = _main( argc, argv);
   [pool release];
   return( rval);
}
