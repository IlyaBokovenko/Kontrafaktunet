#import "Settings.h"

static NSDictionary *_data;

@implementation Settings

+(NSDictionary*)data{
    if(!_data){
      _data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];   
        [_data retain];
    }
     
    return _data;
}

+(NSString*)host{
    return [self.data objectForKey:@"host"];
}

+(NSString*)phone{
    return [self.data objectForKey:@"phone"];
}

@end
