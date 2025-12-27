//
//  DetailObjcViewController.m
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/27.
//

#import "DetailObjcViewController.h"
#import <SafariServices/SafariServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailObjcViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorsLabel;
@property (nonatomic, strong) UILabel *publishedDateLabel;
@property (nonatomic, strong) UIButton *infoButton;
@end

@implementation DetailObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:self.titleLabel];

    self.authorsLabel = [[UILabel alloc] init];
    self.authorsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.authorsLabel.numberOfLines = 0;
    [self.view addSubview:self.authorsLabel];

    self.publishedDateLabel = [[UILabel alloc] init];
    self.publishedDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.publishedDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [self.view addSubview:self.publishedDateLabel];

    self.infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.infoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoButton setTitle:@"View on Web" forState:UIControlStateNormal];
    [self.infoButton addTarget:self action:@selector(openInfoLink) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        [self.authorsLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.authorsLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.authorsLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],

        [self.publishedDateLabel.topAnchor constraintEqualToAnchor:self.authorsLabel.bottomAnchor constant:8],
        [self.publishedDateLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.publishedDateLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],

        [self.infoButton.topAnchor constraintEqualToAnchor:self.publishedDateLabel.bottomAnchor constant:16],
        [self.infoButton.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor]
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)updateUI {
    // Navigation bar should show a fixed localized title, while the on-screen label shows the book's title
    self.navigationItem.title = @"本の詳細";
    self.titleLabel.text = self.bookItem.title ?: @"(No title)";
    if (self.bookItem.authors.count > 0) {
        self.authorsLabel.text = [NSString stringWithFormat:@"Authors: %@", [self.bookItem.authors componentsJoinedByString:@", "]];
    } else {
        self.authorsLabel.text = @"Authors: (Unknown)";
    }
    self.publishedDateLabel.text = self.bookItem.publishedDate ?: @"";
    self.infoButton.hidden = (self.bookItem.infoLink.length == 0);
}

- (void)openInfoLink {
    if (self.bookItem.infoLink.length == 0) return;
    NSURL *url = [NSURL URLWithString:self.bookItem.infoLink];
    if (!url) return;
    if (@available(iOS 9.0, *)) {
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:svc animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
    }
}

@end

NS_ASSUME_NONNULL_END
