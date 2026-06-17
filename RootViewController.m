#import "RootViewController.h"
#import "JailbreakEngine.h"

@interface RootViewController ()
@property (nonatomic, strong) UIView         *infoCard;
@property (nonatomic, strong) UIButton       *jailbreakButton;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGradientBackground];
    [self setupUI];
    [self detectDevice];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.view.bounds;
        }
    }
}

- (void)setupGradientBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    // Снизу #030303 → сверху #3E3E3E
    gradient.colors = @[
        (id)[UIColor colorWithRed:0.243 green:0.243 blue:0.243 alpha:1.0].CGColor, // #3E3E3E сверху
        (id)[UIColor colorWithRed:0.012 green:0.012 blue:0.012 alpha:1.0].CGColor  // #030303 снизу
    ];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint   = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // ── Заголовок "MeowRa1n" ──────────────────────────────
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"MeowRa1n";
    titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    titleLabel.layer.shadowColor   = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset  = CGSizeZero;
    titleLabel.layer.shadowRadius  = 16;
    titleLabel.layer.shadowOpacity = 0.9;
    titleLabel.layer.masksToBounds = NO;
    [titleLabel sizeToFit];

    // ── Лапка — JPEG без template, просто с glow ──────────
    UIImageView *pawView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw"]];
    pawView.contentMode = UIViewContentModeScaleAspectFit;
    pawView.layer.cornerRadius = 6;
    pawView.layer.masksToBounds = NO;
    pawView.layer.shadowColor   = [UIColor whiteColor].CGColor;
    pawView.layer.shadowOffset  = CGSizeZero;
    pawView.layer.shadowRadius  = 14;
    pawView.layer.shadowOpacity = 0.9;

    CGFloat pawSize = 38;
    CGFloat gap     = 12;
    CGFloat totalW  = titleLabel.frame.size.width + gap + pawSize;
    CGFloat startX  = (W - totalW) / 2.0;
    CGFloat topY    = 72;

    titleLabel.frame = CGRectMake(startX, topY, titleLabel.frame.size.width, titleLabel.frame.size.height);
    pawView.frame    = CGRectMake(startX + titleLabel.frame.size.width + gap,
                                  topY + (titleLabel.frame.size.height - pawSize) / 2.0,
                                  pawSize, pawSize);
    [self.view addSubview:titleLabel];
    [self.view addSubview:pawView];

    // ── Подзаголовок ──────────────────────────────────────
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    sub.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, topY + titleLabel.frame.size.height + 8, W, 22);
    [self.view addSubview:sub];

    // ── Карточка ──────────────────────────────────────────
    CGFloat fontSize   = 18.0;
    CGFloat rowHeight  = 46.0;
    CGFloat cardPadV   = 16.0;
    CGFloat cardW      = W - 50;
    CGFloat cardH      = rowHeight * 5 + cardPadV * 2;
    CGFloat cardX      = 25;
    CGFloat cardY      = (H - cardH) / 2.0;

    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:0.22];
    self.infoCard.layer.cornerRadius = 22;
    self.infoCard.layer.masksToBounds = NO;
    self.infoCard.layer.shadowColor   = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 22;
    self.infoCard.layer.shadowOpacity = 0.28;
    [self.view addSubview:self.infoCard];

    NSArray *keys = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    UIColor *keyColor = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0]; // #D9D9D9
    UIFont  *rowFont  = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = cardPadV + i * rowHeight + (rowHeight - (fontSize + 4)) / 2.0;
        UILabel *rowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, rowY, cardW - 40, fontSize + 4)];
        rowLabel.tag = [tags[i] integerValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"• %@  ", keys[i]]
                attributes:@{NSForegroundColorAttributeName: keyColor, NSFontAttributeName: rowFont}];
        [attr appendAttributedString:[[NSAttributedString alloc]
            initWithString:@"..."
                attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: rowFont}]];
        rowLabel.attributedText = attr;
        [self.infoCard addSubview:rowLabel];
    }

    // ── Кнопка Jailbreak ─────────────────────────────────
    CGFloat btnW = W - 60;
    CGFloat btnH = 60;
    CGFloat btnX = 30;
    CGFloat btnY = H - btnH - 40;

    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 18;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.jailbreakButton.layer.shadowColor   = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.7;

    [self.jailbreakButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.jailbreakButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.jailbreakButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)buttonTouchDown:(UIButton *)btn {
    [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        btn.transform = CGAffineTransformMakeScale(0.96, 0.96);
        btn.alpha = 0.85;
    } completion:nil];
}

- (void)buttonTouchUp:(UIButton *)btn {
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:0 animations:^{
        btn.transform = CGAffineTransformIdentity;
        btn.alpha = 1.0;
    } completion:nil];
}

- (void)updateRowTag:(NSInteger)tag value:(NSString *)value {
    UILabel *label = (UILabel *)[self.infoCard viewWithTag:tag];
    if (!label) return;

    NSArray *keyNames = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tagList  = @[@100, @101, @102, @103, @104];
    NSInteger idx = [tagList indexOfObject:@(tag)];
    NSString *keyStr = (idx != NSNotFound) ? keyNames[idx] : @"";

    UIFont  *rowFont  = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
    UIColor *keyColor = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"• %@  ", keyStr]
            attributes:@{NSForegroundColorAttributeName: keyColor, NSFontAttributeName: rowFont}];
    [attr appendAttributedString:[[NSAttributedString alloc]
        initWithString:value
            attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: rowFont}]];

    [UIView transitionWithView:label duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        label.attributedText = attr;
    } completion:nil];
}

- (void)detectDevice {
    [self updateRowTag:100 value:[[UIDevice currentDevice] model]];
    [self updateRowTag:101 value:[[UIDevice currentDevice] systemVersion]];
    [self updateRowTag:102 value:@"Unknown"];
    [self updateRowTag:103 value:@"Apple Silicon"];
    [self updateRowTag:104 value:@"Ready"];
}

@end
