//
//  ZRSearchViewController.m
//  iFinder
//
//  Created by VictorZhang on 17/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRSearchViewController.h"
#import "ZRFileUtil.h"
#import "ZRFileModel.h"
#import "UIView+Toast.h"
#import "ZRMainViewController.h"

#define  ZRCellForHeight        55

@interface ZRSearchViewController()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ZRSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Files";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
 
    [self configureUI];
}

- (void)configureUI
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchBar.frame = CGRectMake(0, 60, self.view.frame.size.width, 44);
    searchController.searchResultsUpdater = self;
    searchController.searchBar.placeholder = @"Search";
    searchController.delegate = self;
    searchController.searchBar.delegate = self;
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    searchController.hidesNavigationBarDuringPresentation = NO;
//    searchController.dimsBackgroundDuringPresentation = NO;
    _searchController = searchController;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
//    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableHeaderView = searchController.searchBar;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
//    NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:views]];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ZRCellForHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuse_cell = @"Searchbar_dir_reuse_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_cell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse_cell];
    }
    
    ZRFileModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.path;
    cell.imageView.image = [UIImage imageNamed:model.fileIcon];
    if (model.isDirectory || model.fileType == ZRFileTypeFolder) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZRFileModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    NSError *error = nil;
    NSArray *nextPathArray = [ZRFileUtil getDirectoriesByPathname:model.path error:&error];
    if (nextPathArray.count <= 0) {
        [self.view makeToast:[NSString stringWithFormat:@"No more content was found in %@", model.path] duration:1.0 position:CSToastPositionCenter];
    }
    
    [self didDismissSearchController:self.searchController];
    
    ZRMainViewController *nextVC = [[ZRMainViewController alloc] init];
    nextVC.directories = nextPathArray;
    nextVC.isSubPath = YES;
    nextVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{

}

#pragma mark UISearchControllerDelegate
-(void)didDismissSearchController:(UISearchController *)searchController
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView reloadData];
}


#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchText:searchText];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchText:searchBar.text];
}

- (void)searchText:(NSString *)searchText
{
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray<ZRFileModel *> * list = [ZRFileUtil getDesignatedDirectoriesWithName:text];
    _dataArray = list;
}

@end
