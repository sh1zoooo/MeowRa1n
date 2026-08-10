#import "RootViewController.h"

@interface RootViewController ()
@property (nonatomic, strong) UIView   *infoCard;
@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) NSMutableArray<UILabel *> *logLabelStack;
@property (nonatomic, strong) UILabel  *stepCounterLabel;
@property (nonatomic, strong) UIView   *logGlowBackdrop;
@property (nonatomic, strong) NSArray<NSString *> *jailbreakSteps;
@property (nonatomic, assign) NSInteger jailbreakStepIndex;
@property (nonatomic, assign) BOOL isRunning;
@end

// Акцент темы — монохромное серебристое свечение
static inline UIColor *MRNeonAccent(CGFloat alpha) {
    return [UIColor colorWithWhite:1.0 alpha:alpha];
}

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
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = self.view.bounds;
    g.colors = @[
        (id)[UIColor colorWithRed:0.243 green:0.243 blue:0.243 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.150 green:0.150 blue:0.150 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.012 green:0.012 blue:0.012 alpha:1.0].CGColor
    ];
    g.locations = @[@0.0, @0.5, @1.0];
    g.startPoint = CGPointMake(0.5, 0.0);
    g.endPoint   = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:g atIndex:0];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // ── Заголовок ─────────────────────────────────────────
    UILabel *title = [[UILabel alloc] init];
    title.text = @"MeowRa1n";
    UIFont *sfDisplay = [UIFont fontWithName:@"SFUIDisplay-Medium" size:40];
    title.font = sfDisplay ?: [UIFont systemFontOfSize:40 weight:UIFontWeightHeavy];
    title.textColor = [UIColor colorWithWhite:0.808 alpha:1.0];
    title.layer.shadowColor   = [UIColor whiteColor].CGColor;
    title.layer.shadowOffset  = CGSizeZero;
    title.layer.shadowRadius  = 16;
    title.layer.shadowOpacity = 0.9;
    title.layer.masksToBounds = NO;
    [title sizeToFit];

    // ── Лапка ─────────────────────────────────────────────
    UIImageView *paw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw"]];
    paw.contentMode = UIViewContentModeScaleAspectFit;
    paw.layer.shadowColor   = [UIColor whiteColor].CGColor;
    paw.layer.shadowOffset  = CGSizeZero;
    paw.layer.shadowRadius  = 14;
    paw.layer.shadowOpacity = 0.85;
    paw.layer.masksToBounds = NO;

    CGFloat pawSize = 38;
    CGFloat gap     = 10;
    CGFloat totalW  = title.frame.size.width + gap + pawSize;
    CGFloat startX  = (W - totalW) / 2.0;
    CGFloat topY    = 72;

    title.frame = CGRectMake(startX, topY, title.frame.size.width, title.frame.size.height);
    paw.frame   = CGRectMake(startX + title.frame.size.width + gap,
                             topY + (title.frame.size.height - pawSize) / 2.0,
                             pawSize, pawSize);
    [self.view addSubview:title];
    [self.view addSubview:paw];

    // ── Подзаголовок ──────────────────────────────────────
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    sub.textColor = [UIColor colorWithWhite:0.808 alpha:1.0];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, topY + title.frame.size.height + 8, W, 22);
    [self.view addSubview:sub];

    // ── Кнопка (считаем геометрию заранее — карточка равняется по ней) ──
    CGFloat sideMargin = 30;
    CGFloat btnW = W - sideMargin * 2;
    CGFloat btnH = 60;
    CGFloat btnY = H - btnH - 40;

    // ── Карточка ──────────────────────────────────────────
    CGFloat fontSize  = 19.0;
    CGFloat rowH      = 42.0;
    CGFloat padV      = 18.0;
    CGFloat cardW     = btnW;                 // та же ширина, что и у кнопки
    CGFloat cardH     = rowH * 5 + padV * 2;

    CGFloat contentTop    = sub.frame.origin.y + sub.frame.size.height; // низ подзаголовка
    CGFloat contentBottom = btnY;                                       // верх кнопки
    CGFloat cardX = roundf((W - cardW) / 2.0);                          // строго по центру экрана по горизонтали
    // Кнопка снизу визуально "тяжелее" (заливка + тень), поэтому чисто геометрический центр
    // выглядит как смещение карточки вниз. Компенсируем оптическим сдвигом вверх.
    CGFloat opticalOffset = 20.0;
    CGFloat cardY = roundf(contentTop + (contentBottom - contentTop - cardH) / 2.0 - opticalOffset);

    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    self.infoCard.backgroundColor = [UIColor clearColor];
    self.infoCard.layer.cornerRadius = 22;
    self.infoCard.layer.masksToBounds = NO;
    // Неоновое свечение самой карточки
    self.infoCard.layer.shadowColor   = MRNeonAccent(1.0).CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 24;
    self.infoCard.layer.shadowOpacity = 0.35;
    [self.view addSubview:self.infoCard];

    // Настоящий blur вместо плоской заливки
    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:
        [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]];
    blur.frame = self.infoCard.bounds;
    blur.layer.cornerRadius = 22;
    blur.clipsToBounds = YES;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.infoCard addSubview:blur];

    // Тонкий серебристый бордер поверх blur
    self.infoCard.layer.borderWidth = 1.0;
    self.infoCard.layer.borderColor = MRNeonAccent(0.35).CGColor;

    // Стеклянный "хайлайт" — градиент сверху вниз, имитирующий отражение света
    CAGradientLayer *glassHighlight = [CAGradientLayer layer];
    glassHighlight.frame = self.infoCard.bounds;
    glassHighlight.cornerRadius = 22;
    glassHighlight.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.08].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    glassHighlight.locations = @[@0.0, @0.45];
    [blur.contentView.layer addSublayer:glassHighlight];

    // ── Строки карточки ───────────────────────────────────
    NSArray *keys = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    UIColor *keyColor = [UIColor colorWithWhite:0.851 alpha:1.0]; // #D9D9D9
    UIFont  *keyFont  = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    UIFont  *valFont  = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];

    // Ширину значения выравниваем по самому длинному ключу — единая колонка
    CGFloat maxKeyW = 0;
    for (NSString *k in keys) {
        NSString *bulleted = [NSString stringWithFormat:@"• %@", k];
        CGSize sz = [bulleted sizeWithAttributes:@{NSFontAttributeName: keyFont}];
        maxKeyW = MAX(maxKeyW, sz.width);
    }
    CGFloat valX = 24 + maxKeyW + 8;

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = padV + i * rowH;
        BOOL isStatusRow = (i == 4); // строка "Jailbreak:"

        // Ключ "• Device:"
        UILabel *keyLabel = [[UILabel alloc] init];
        keyLabel.text = [NSString stringWithFormat:@"• %@", keys[i]];
        keyLabel.font = keyFont;
        keyLabel.textColor = keyColor;
        [keyLabel sizeToFit];
        keyLabel.frame = CGRectMake(24, rowY + (rowH - keyLabel.frame.size.height) / 2.0,
                                    keyLabel.frame.size.width, keyLabel.frame.size.height);
        [blur.contentView addSubview:keyLabel];

        // Значение — единая колонка для всех строк, все значения в неоновом белом стиле
        UILabel *valLabel = [[UILabel alloc] init];
        valLabel.tag = [tags[i] integerValue];
        valLabel.text = @"...";
        valLabel.font = isStatusRow ? [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold] : valFont;
        valLabel.textColor = MRNeonAccent(1.0);
        valLabel.layer.shadowColor   = MRNeonAccent(1.0).CGColor;
        valLabel.layer.shadowOffset  = CGSizeZero;
        valLabel.layer.shadowRadius  = 8;
        valLabel.layer.shadowOpacity = 0.9;
        valLabel.layer.masksToBounds = NO;
        valLabel.frame = CGRectMake(valX, rowY + (rowH - keyLabel.frame.size.height) / 2.0,
                                    cardW - valX - 16, keyLabel.frame.size.height);
        [blur.contentView addSubview:valLabel];
    }

    // ── Кнопка ────────────────────────────────────────────
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(sideMargin, btnY, btnW, btnH);
    self.jailbreakButton.backgroundColor = [UIColor colorWithWhite:0.624 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 18;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.jailbreakButton.layer.shadowColor   = [UIColor colorWithWhite:0.624 alpha:1.0].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.7;
    [self.jailbreakButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.jailbreakButton addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.jailbreakButton addTarget:self action:@selector(jailbreakTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)btnDown:(UIButton *)btn { [UIView animateWithDuration:0.1 animations:^{ btn.alpha = 0.6; }]; }
- (void)btnUp:(UIButton *)btn   { [UIView animateWithDuration:0.18 animations:^{ btn.alpha = 1.0; }]; }

- (void)setRowTag:(NSInteger)tag value:(NSString *)val {
    UILabel *lbl = (UILabel *)[self.infoCard viewWithTag:tag];
    if (!lbl) return;
    [UIView transitionWithView:lbl duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        lbl.text = val;
    } completion:nil];
}

- (void)detectDevice {
    [self setRowTag:100 value:[[UIDevice currentDevice] model]];
    [self setRowTag:101 value:[[UIDevice currentDevice] systemVersion]];
    [self setRowTag:102 value:@"Unknown"];
    [self setRowTag:103 value:@"Apple Silicon"];
    [self setRowTag:104 value:@"Ready"];
}

#pragma mark - Jailbreak sequence

- (void)jailbreakTapped:(UIButton *)btn {
    if (self.isRunning) return;
    self.isRunning = YES;
    self.logLabelStack = [NSMutableArray array];

    self.jailbreakSteps = @[
        @"Initializing MeowRa1n",
        @"Scanning device",
        @"Locating kernel exploit",
        @"Gaining kernel r/w",
        @"Bypassing PAC",
        @"Disabling AMFI",
        @"Patching sandbox",
        @"Mounting rootfs",
        @"Installing MeowSubstrate",
        @"Deploying Sileo",
        @"Finalizing patches"
    ];
    self.jailbreakStepIndex = 0;

    [self setButtonRunningState:YES];
    [self dismissCardThenBegin];
}

// Кнопка больше не исчезает — просто тускнеет и перестаёт быть кликабельной
- (void)setButtonRunningState:(BOOL)running {
    self.jailbreakButton.userInteractionEnabled = !running;
    [UIView animateWithDuration:0.35 animations:^{
        self.jailbreakButton.alpha = running ? 0.4 : 1.0;
        self.jailbreakButton.layer.shadowOpacity = running ? 0.1 : 0.7;
    }];
}

// 1. Карточка уходит единым движением (scale + fade + сдвиг), кнопка остаётся на месте
- (void)dismissCardThenBegin {
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.85
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        CGAffineTransform t = CGAffineTransformConcat(
            CGAffineTransformMakeScale(0.82, 0.82),
            CGAffineTransformMakeTranslation(0, -24));
        self.infoCard.transform = t;
        self.infoCard.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.infoCard removeFromSuperview];
        [self showFlashThenStartLog];
    }];
}

// 2. Вспышка ASCII-арта кота по центру экрана — крупная (~2.5x прежнего размера)
- (void)showFlashThenStartLog {
    UIImage *catImage = [UIImage imageNamed:@"cat_ascii"];
    UIImageView *flash = [[UIImageView alloc] initWithImage:catImage];
    flash.contentMode = UIViewContentModeScaleAspectFit;
    flash.alpha = 0.0;
    CGFloat side = MIN(self.view.bounds.size.width * 0.92, 650);
    flash.frame = CGRectMake(0, 0, side, side);
    flash.center = self.view.center;
    flash.layer.shadowColor = [UIColor whiteColor].CGColor;
    flash.layer.shadowOffset = CGSizeZero;
    flash.layer.shadowRadius = 32;
    flash.layer.shadowOpacity = 0.55;
    [self.view addSubview:flash];

    [UIView animateWithDuration:0.07 animations:^{
        flash.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 delay:0.12 options:0 animations:^{
            flash.alpha = 0.0;
        } completion:^(BOOL finished2) {
            [flash removeFromSuperview];
            [self setupLogGlowBackdrop];
            [self setupStepCounter];
            [self advanceLogStep];
        }];
    }];
}

// Мягкое радиальное свечение позади лог-стека — для атмосферы, не голый текст на фоне
- (void)setupLogGlowBackdrop {
    CGFloat size = MIN(self.view.bounds.size.width, self.view.bounds.size.height) * 0.9;
    UIView *glow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    glow.center = CGPointMake(self.view.center.x, self.view.center.y - 10);
    glow.userInteractionEnabled = NO;
    glow.alpha = 0.0;

    CAGradientLayer *radial = [CAGradientLayer layer];
    radial.type = kCAGradientLayerRadial;
    radial.frame = glow.bounds;
    radial.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.10].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    radial.startPoint = CGPointMake(0.5, 0.5);
    radial.endPoint   = CGPointMake(1.0, 1.0);
    [glow.layer addSublayer:radial];

    [self.view insertSubview:glow belowSubview:self.jailbreakButton];
    self.logGlowBackdrop = glow;
    [UIView animateWithDuration:0.5 animations:^{
        glow.alpha = 1.0;
    }];
}

- (void)setupStepCounter {
    UILabel *counter = [[UILabel alloc] init];
    counter.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    counter.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    counter.textAlignment = NSTextAlignmentCenter;
    counter.alpha = 0.0;
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    counter.frame = CGRectMake(0, H - 130, W, 20);
    [self.view addSubview:counter];
    self.stepCounterLabel = counter;
    [UIView animateWithDuration:0.4 animations:^{
        counter.alpha = 1.0;
    }];
}

// 3. Цепочка логов по центру экрана — старые строки не пропадают, а копятся стеком выше
- (void)advanceLogStep {
    if (self.jailbreakStepIndex >= self.jailbreakSteps.count) {
        [self finishWithResultAlert];
        return;
    }
    NSString *text = self.jailbreakSteps[self.jailbreakStepIndex];
    self.jailbreakStepIndex += 1;

    self.stepCounterLabel.text = [NSString stringWithFormat:@"%ld / %ld",
                                   (long)self.jailbreakStepIndex, (long)self.jailbreakSteps.count];
    [self showLogStep:text];

    // Держим строку на экране заметно дольше, чтобы не выглядело фейково-быстро
    CGFloat baseDelay = 1.7;
    CGFloat jitter = ((arc4random_uniform(500)) / 1000.0) - 0.25; // ±0.25s
    CGFloat delay = MAX(1.2, baseDelay + jitter);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self advanceLogStep];
    });
}

// Параметры внешнего вида для каждого "поколения" строки в стеке истории (0 = самая новая)
- (void)styleLabel:(UILabel *)lbl forGeneration:(NSInteger)gen baseCenter:(CGPoint)baseCenter {
    CGFloat rowSpacing = 40.0;
    CGFloat scale       = MAX(0.42, 1.0 - gen * 0.16);
    CGFloat grayLevel   = MAX(0.30, 1.0 - gen * 0.16);
    CGFloat labelAlpha  = MAX(0.28, 1.0 - gen * 0.16);
    CGFloat shadowOp    = MAX(0.0, 0.85 - gen * 0.28);

    lbl.transform = CGAffineTransformMakeScale(scale, scale);
    lbl.center = CGPointMake(baseCenter.x, baseCenter.y - gen * rowSpacing);
    lbl.textColor = [UIColor colorWithWhite:grayLevel alpha:1.0];
    lbl.alpha = labelAlpha;
    lbl.layer.shadowOpacity = shadowOp;
}

- (void)showLogStep:(NSString *)text {
    NSString *bulleted = [NSString stringWithFormat:@"• %@", text];
    CGPoint baseCenter = CGPointMake(self.view.center.x, self.view.center.y - 10);
    NSInteger maxVisibleGenerations = 4; // 0..4 = до 5 строк одновременно на экране

    // Продвигаем все существующие строки на одно "поколение" выше по стеку
    NSMutableArray<UILabel *> *toRemove = [NSMutableArray array];
    for (UILabel *lbl in self.logLabelStack) {
        NSInteger gen = lbl.tag + 1;
        lbl.tag = gen;
        if (gen > maxVisibleGenerations) {
            [toRemove addObject:lbl];
            continue;
        }
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self styleLabel:lbl forGeneration:gen baseCenter:baseCenter];
        } completion:nil];
    }
    for (UILabel *lbl in toRemove) {
        [self.logLabelStack removeObject:lbl];
        [UIView animateWithDuration:0.4 animations:^{
            lbl.alpha = 0.0;
        } completion:^(BOOL finished) {
            [lbl removeFromSuperview];
        }];
    }

    // Новая строка — крупная, белая, появляется в центре (поколение 0)
    UILabel *newLabel = [[UILabel alloc] init];
    newLabel.tag = 0;
    newLabel.text = bulleted;
    newLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.numberOfLines = 2;
    newLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    newLabel.layer.shadowOffset = CGSizeZero;
    newLabel.layer.shadowRadius = 10;
    newLabel.layer.masksToBounds = NO;

    CGFloat W = self.view.bounds.size.width;
    newLabel.frame = CGRectMake(24, 0, W - 48, 60);
    newLabel.center = baseCenter;
    newLabel.alpha = 0.0;
    newLabel.transform = CGAffineTransformMakeScale(0.85, 0.85);
    newLabel.textColor = [UIColor whiteColor];
    [self.view insertSubview:newLabel aboveSubview:self.logGlowBackdrop];

    [UIView animateWithDuration:0.45
                          delay:0.05
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:0
                     animations:^{
        newLabel.alpha = 1.0;
        newLabel.transform = CGAffineTransformIdentity;
    } completion:nil];

    [self.logLabelStack addObject:newLabel];
}

// 4. Финальный экран — имитация системного алерта iOS
- (void)finishWithResultAlert {
    // Убираем весь накопленный стек логов и glow-подложку одним плавным затуханием
    for (UILabel *lbl in self.logLabelStack) {
        [UIView animateWithDuration:0.3 animations:^{
            lbl.alpha = 0.0;
            lbl.transform = CGAffineTransformScale(lbl.transform, 0.85, 0.85);
        } completion:^(BOOL finished) {
            [lbl removeFromSuperview];
        }];
    }
    [self.logLabelStack removeAllObjects];

    UIView *glow = self.logGlowBackdrop;
    UILabel *counter = self.stepCounterLabel;
    [UIView animateWithDuration:0.3 animations:^{
        glow.alpha = 0.0;
        counter.alpha = 0.0;
    } completion:^(BOOL finished) {
        [glow removeFromSuperview];
        [counter removeFromSuperview];
    }];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"success??"
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // TODO: доделаем позже — пока по нажатию OK ничего не происходит
        self.isRunning = NO;
        [self setButtonRunningState:NO];
    }];
    [alert addAction:ok];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
