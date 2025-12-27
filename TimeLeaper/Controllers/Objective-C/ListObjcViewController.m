//
//  ListObjcViewController.m
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

#import "ListObjcViewController.h"
#import <SafariServices/SafariServices.h>
#import "DetailObjcViewController.h"

@interface ListObjcViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<BookItem *> *items;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ListObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    // Show navigation bar title
    self.navigationItem.title = @"本を探す";

    // Search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search Google Books";
    [self.view addSubview:self.searchBar];

    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    // Activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.activityIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];

    // Register default cell
    // Do not register a class so we can create a cell with UITableViewCellStyleSubtitle

    // Initial empty state
    self.items = @[];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *query = searchBar.text ?: @"";
    if (query.length == 0) return;
    [self fetchBooksForQuery:query];
}

#pragma mark - Networking

- (void)fetchBooksForQuery:(NSString *)query {
    [self.activityIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [[ItemService sharedService] searchBooksForQuery:query maxResults:20 completion:^(NSArray<BookItem *> * _Nullable items, NSError * _Nullable error) {
        __strong typeof(weakSelf) strong = weakSelf;
        if (!strong) return;
        [strong.activityIndicator stopAnimating];
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [strong presentViewController:alert animated:YES completion:nil];
            return;
        }
        strong.items = items ?: @[];
        [strong.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    BookItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.title ?: @"(No title)";
    if (item.authors.count > 0) {
        cell.detailTextLabel.text = [item.authors componentsJoinedByString:@", "];
    } else {
        cell.detailTextLabel.text = item.publishedDate ?: @"";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BookItem *item = self.items[indexPath.row];
    // Create detail view controller and pass the book
    DetailObjcViewController *detail = [[DetailObjcViewController alloc] init];
    detail.bookItem = item;

    UINavigationController *nav = self.navigationController;
    if (!nav) {
        // Try to find an existing nav in scenes
        UIApplication *app = UIApplication.sharedApplication;
        UIWindow *targetWindow = nil;
        if (@available(iOS 13.0, *)) {
            // Prefer a key window from an active scene
            for (UIScene *scene in app.connectedScenes) {
                if (![scene isKindOfClass:[UIWindowScene class]]) continue;
                UIWindowScene *windowScene = (UIWindowScene *)scene;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow) { targetWindow = w; break; }
                }
#pragma clang diagnostic pop
                if (targetWindow) break;
            }
            // Fallback: pick first available window in any scene
            if (!targetWindow) {
                for (UIScene *scene in app.connectedScenes) {
                    if (![scene isKindOfClass:[UIWindowScene class]]) continue;
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    if (windowScene.windows.count > 0) { targetWindow = windowScene.windows.firstObject; break; }
#pragma clang diagnostic pop
                }
            }
        } else {
            // Accessing UIApplication.windows is deprecated on newer SDKs; this fallback is only used on older OS versions.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            for (UIWindow *w in app.windows) {
                if (w.isKeyWindow) { targetWindow = w; break; }
            }
            if (!targetWindow && app.windows.count > 0) targetWindow = app.windows.firstObject;
#pragma clang diagnostic pop
        }

        UIViewController *root = targetWindow.rootViewController;
        if ([root isKindOfClass:[UINavigationController class]]) nav = (UINavigationController *)root;
        else if (root.navigationController) nav = root.navigationController;
        else {
            // Create a new nav controller with self as root so navigation bar appears and push works
            if (targetWindow) {
                UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:self];
                targetWindow.rootViewController = newNav;
                [targetWindow makeKeyAndVisible];
                nav = newNav;
            }
        }
    }

    if (nav) {
        [nav pushViewController:detail animated:YES];
    } else {
        // Last resort: present modally inside nav
        UINavigationController *presentNav = [[UINavigationController alloc] initWithRootViewController:detail];
        [self presentViewController:presentNav animated:YES completion:nil];
    }
}

@end
