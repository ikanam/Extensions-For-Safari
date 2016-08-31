//
//  ActionViewController.m
//  ExtensionsForSafariAction
//
//  Created by Tian on 16/8/30.
//  Copyright © 2016年 JerryTian. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Realm/Realm.h>
#import "SnippetTableViewCell.h"
#import "CodeSnippet.h"

@interface ActionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) RLMResults *snippets;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.fileURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.jerrytian.extensionsforsafari"] URLByAppendingPathComponent:@"db.realm"];
    [RLMRealmConfiguration setDefaultConfiguration:configuration];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SnippetTableViewCell" bundle:nil] forCellReuseIdentifier:@"SnippetTableViewCell"];
    
    [self loadSnippets];
    
    BOOL foundDictionary = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems)
    {
        for (NSItemProvider *itemProvider in item.attachments)
        {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList])
            {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *dictionary, NSError *error) {
                    if (dictionary != nil)
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSDictionary *jsDict = dictionary[NSExtensionJavaScriptPreprocessingResultsKey];
                            if (jsDict != nil)
                            {
                                NSString *urlStr = jsDict[@"baseURI"];
                                NSLog(@"%@", urlStr);
                            }
                        }];
                    }
                }];
                
                foundDictionary = YES;
                break;
            }
        }
        
        if (foundDictionary)
            break;
    }
}


#pragma mark - Event Response

- (IBAction)didTapFireBugButton:(UIBarButtonItem *)sender {
    NSString *fireBugJs =
    @"(function(F,i,r,e,b,u,g,L,I,T,E){if(F.getElementById(b))return;E=F[i+'NS']&&F.documentElement.namespaceURI;E=E?F[i+'NS'](E,'script'):F[i]('script');E[r]('id',b);E[r]('src',I+g+T);E[r](b,u);(F[e]('head')[0]||F[e]('body')[0]).appendChild(E);E=new Image;E[r]('src',I+L);})(document,'createElement','setAttribute','getElementsByTagName','FirebugLite','4','firebug-lite.js','releases/lite/latest/skin/xp/sprite.png','https://getfirebug.com/','#startOpened')";
    [self excuteJavaScriptOnSafari:fireBugJs];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CodeSnippet *snippet = [self.snippets objectAtIndex:indexPath.row];
    
    [self excuteJavaScriptOnSafari:snippet.code];
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

#pragma mark - Private Method

- (void)loadSnippets {
    self.snippets = [CodeSnippet allObjects];
    [self.tableView reloadData];
}


- (void)excuteJavaScriptOnSafari:(NSString *)js {
    NSExtensionItem *extensionItem = [[NSExtensionItem alloc] init];
    extensionItem.attachments = @[[[NSItemProvider alloc] initWithItem: @{NSExtensionJavaScriptFinalizeArgumentKey: @{@"jsCode" : js}} typeIdentifier:(NSString *)kUTTypePropertyList]];
    
    [self.extensionContext completeRequestReturningItems:@[extensionItem] completionHandler:nil];
}

@end
