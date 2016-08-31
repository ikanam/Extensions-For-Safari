//
//  SnippetsTableViewController.m
//  ExtensionsForSafari
//
//  Created by Tian on 16/8/31.
//  Copyright © 2016年 JerryTian. All rights reserved.
//

#import "SnippetsTableViewController.h"
#import "EditorViewController.h"
#import "SnippetTableViewCell.h"

@interface SnippetsTableViewController ()

@property (nonatomic, strong) RLMResults *snippets;

@end

@implementation SnippetsTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SnippetTableViewCell" bundle:nil] forCellReuseIdentifier:@"SnippetTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSnippets];
}

- (IBAction)didTapAddSnippetButton:(UIBarButtonItem *)sender {
    [self createNewSnippetSuccess:^(CodeSnippet *snippet) {
        if (snippet) {
            [self performSegueWithIdentifier:@"ShowEditorSegue" sender:snippet];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.snippets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SnippetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SnippetTableViewCell" forIndexPath:indexPath];
    CodeSnippet *snippet = [self.snippets objectAtIndex:indexPath.row];
    cell.nameLabel.text = snippet.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CodeSnippet *snippet = [self.snippets objectAtIndex:indexPath.row];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm transactionWithBlock:^{
            [realm deleteObject:snippet];
        }];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CodeSnippet *snippet = [self.snippets objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"ShowEditorSegue" sender:snippet];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowEditorSegue"]) {
        if ([sender isKindOfClass:[CodeSnippet class]]) {
            EditorViewController *editorViewController = segue.destinationViewController;
            editorViewController.snippet = sender;
        }
    }
}

#pragma mark - Private Method

- (void)loadSnippets {
    self.snippets = [CodeSnippet allObjects];
    if (!self.snippets.count) {
        
    }
    [self.tableView reloadData];
}

- (void)createNewSnippetSuccess:(void (^)(CodeSnippet *snippet))success {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建代码片段" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"名称";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CodeSnippet *snippet = [[CodeSnippet alloc] init];
        snippet.ID = [[NSUUID UUID] UUIDString];
        snippet.name = alertController.textFields.firstObject.text;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:snippet];
        }];
        success(snippet);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
