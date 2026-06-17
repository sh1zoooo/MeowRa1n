#import "RootViewController.h"
#import "JailbreakEngine.h"

static void applyGlow(UIView *view, UIColor *color, CGFloat radius, CGFloat opacity) {
    view.layer.shadowColor   = color.CGColor;
    view.layer.shadowOffset  = CGSizeZero;
    view.layer.shadowRadius  = radius;
    view.layer.shadowOpacity = opacity;
    view.layer.masksToBounds = NO;
}

static void applyLabelGlow(UILabel *label, UIColor *color, CGFloat radius, CGFloat opacity) {
    label.layer.shadowColor   = color.CGColor;
    label.layer.shadowOffset  = CGSizeZero;
    label.layer.shadowRadius  = radius;
    label.layer.shadowOpacity = opacity;
    label.layer.masksToBounds = NO;
}

@interface RootViewController ()
@property (nonatomic, strong) UIView        *infoCard;
@property (nonatomic, strong) UILabel       *statusLabel;
@property (nonatomic, strong) UIButton      *jailbreakButton;
@property (nonatomic, strong) UITextView    *logView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) JailbreakEngine *engine;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.165 green:0.165 blue:0.165 alpha:1.0];
    [self setupUI];
    [self detectDevice];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // --- Заголовок "MeowRa1n 🐾" ---
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"MeowRa1n 🐾";
    titleLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0, 72, W, 52);
    applyLabelGlow(titleLabel, [UIColor whiteColor], 18, 0.95);
    [self.view addSubview:titleLabel];

    // --- Подзаголовок ---
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    sub.textColor = [UIColor colorWithWhite:0.60 alpha:1.0];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, 130, W, 22);
    applyLabelGlow(sub, [UIColor whiteColor], 6, 0.35);
    [self.view addSubview:sub];

    // --- Карточка ---
    CGFloat cardX  = 20;
    CGFloat cardY  = H * 0.33;
    CGFloat cardW  = W - 40;
    CGFloat cardH  = 230;
    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.225 green:0.225 blue:0.225 alpha:1.0];
    self.infoCard.layer.cornerRadius = 24;
    // Glow вокруг карточки
    self.infoCard.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 22;
    self.infoCard.layer.shadowOpacity = 0.18;
    self.infoCard.layer.masksToBounds = NO;
    [self.view addSubview:self.infoCard];

    NSArray *keys = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    CGFloat rowH  = cardH / 5.0;

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = i * rowH;

        // Буллет
        UILabel *dot = [[UILabel alloc] initWithFrame:CGRectMake(22, rowY + (rowH - 22) / 2, 16, 22)];
        dot.text = @"•";
        dot.font = [UIFont systemFontOfSize:15];
        dot.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        [self.infoCard addSubview:dot];

        // Ключ
        UILabel *key = [[UILabel alloc] initWithFrame:CGRectMake(38, rowY + (rowH - 22) / 2, 100, 22)];
        key.text = keys[i];
        key.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        key.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        [self.infoCard addSubview:key];

        // Значение
        UILabel *val = [[UILabel alloc] initWithFrame:CGRectMake(140, rowY + (rowH - 22) / 2, cardW - 160, 22)];
        val.tag = [tags[i] integerValue];
        val.text = @"...";
        val.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        val.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        val.textAlignment = NSTextAlignmentRight;
        applyLabelGlow(val, [UIColor whiteColor], 8, 0.55);
        [self.infoCard addSubview:val];
    }
    self.statusLabel = (UILabel *)[self.infoCard viewWithTag:104];

    // --- Progress bar (скрыт) ---
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(20, cardY + cardH + 14, W - 40, 4);
    self.progressView.progressTintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.progressView.trackTintColor    = [UIColor colorWithWhite:0.25 alpha:1.0];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    // --- Лог (скрыт) ---
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, cardY + cardH + 26, W - 40, 130)];
    self.logView.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.09 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.3 green:0.9 blue:0.5 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.layer.cornerRadius = 12;
    self.logView.editable = NO;
    self.logView.hidden = YES;
    [self.view addSubview:self.logView];

    // --- Кнопка Jailbreak ---
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(20, H - 95, W - 40, 62);
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.45 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 20;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    // Glow вокруг кнопки
    self.jailbreakButton.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.20;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)detectDevice {
    UILabel *dev   = (UILabel *)[self.infoCard viewWithTag:100];
    UILabel *ios   = (UILabel *)[self.infoCard viewWithTag:101];
    UILabel *model = (UILabel *)[self.infoCard viewWithTag:102];
    UILabel *chip  = (UILabel *)[self.infoCard viewWithTag:103];

    dev.text   = [[UIDevice currentDevice] model];
    ios.text   = [[UIDevice currentDevice] systemVersion];
    model.text = @"Unknown";
    chip.text  = @"Apple Silicon";

    self.statusLabel.text      = @"Ready";
    self.statusLabel.textColor = [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0];
    applyLabelGlow(self.statusLabel, [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0], 10, 0.80);
}

- (void)startJailbreak {
    self.jailbreakButton.enabled = NO;
    [self.jailbreakButton setTitle:@"Running..." forState:UIControlStateNormal];
    self.progressView.hidden = NO;
    self.logView.hidden = NO;
    self.logView.text = @"";
    self.statusLabel.text = @"Working...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.04 alpha:1.0];
    applyLabelGlow(self.statusLabel, [UIColor colorWithRed:1.0 green:0.84 blue:0.04 alpha:1.0], 10, 0.80);

    self.engine = [[JailbreakEngine alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.engine runWithLogCallback:^(NSString *line, float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.logView.text = [weakSelf.logView.text stringByAppendingFormat:@"%@\n", line];
            [weakSelf.logView scrollRangeToVisible:NSMakeRange(weakSelf.logView.text.length, 0)];
            [weakSelf.progressView setProgress:progress animated:YES];
        });
    } completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.jailbreakButton setTitle:@"Done! 🐾" forState:UIControlStateNormal];
            weakSelf.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.07 green:0.28 blue:0.12 alpha:1.0];
            weakSelf.statusLabel.text = @"Active";
            weakSelf.statusLabel.textColor = [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0];
            applyLabelGlow(weakSelf.statusLabel, [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0], 10, 0.80);
        });
    }];
}

@end
