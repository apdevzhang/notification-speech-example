//
//  NotificationService.m
//  NotificationService
//
//  Created by BANYAN on 2018/4/6.
//  Copyright © 2018年 BANYAN. All rights reserved.
//

#ifdef DEBUG
#define DLog(FORMAT, ...) fprintf(stderr, "%s [Line %zd]\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define DLog(FORMAT, ...) nil
#endif

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>


@interface NotificationService () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;

@end

@implementation NotificationService

- (AVSpeechSynthesizer *)speechSynthesizer {
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

#pragma MARK - 仅仅适用于远程推送
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    [self speechContentBody:self.bestAttemptContent.body];
}

- (void)serviceExtensionTimeWillExpire {
    [self stopSpeech];
    self.contentHandler(self.bestAttemptContent);
}

- (void)speechContentBody:(NSString *)contentBody {
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:contentBody];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    [self.speechSynthesizer speakUtterance:utterance];
}

- (void)stopSpeech {
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.contentHandler(self.bestAttemptContent);
}

@end
