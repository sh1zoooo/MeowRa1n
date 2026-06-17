#import <Foundation/Foundation.h>

typedef void (^LogCallback)(NSString *line, float progress);
typedef void (^CompletionCallback)(BOOL success);

@interface JailbreakEngine : NSObject
- (void)runWithLogCallback:(LogCallback)log completion:(CompletionCallback)completion;
@end