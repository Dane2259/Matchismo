//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Sanjib Ahmad on 11/3/13.
//  Copyright (c) 2013 <>< ObjectCoder. All rights reserved.
//

#import "CardGameViewController.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *matchModeControl;
@property (nonatomic) NSInteger numberOfCardsToPlayWith;
@property (weak, nonatomic) IBOutlet UILabel *matchModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end

// Will show all card content during game - useful for testing game logic
static const BOOL CARD_CONTENT_CHEAT = NO;

@implementation CardGameViewController

- (CardMatchingGame *)game
{
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                          usingDeck:[self createDeck]
                                             numberOfCardsToPlayWith:self.numberOfCardsToPlayWith];
    return _game;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (NSInteger)numberOfCardsToPlayWith
{
    if (!_numberOfCardsToPlayWith) _numberOfCardsToPlayWith = 2;
    return _numberOfCardsToPlayWith;
}


- (IBAction)chooseMatchMode:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) {
        // 3-card match mode
        self.numberOfCardsToPlayWith = 3;
        self.matchModeLabel.text = @"Match Mode: 3-Cards";
    } else {
        // 2-card match mode
        self.numberOfCardsToPlayWith = 2;
        self.matchModeLabel.text = @"Match Mode: 2-Cards";
    }
}

#pragma mark - redeal cards

- (IBAction)redealCardsAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Re-deal Cards?"
                                                    message:@"This will reset your current score."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self redealCards];
    }
}

- (void)redealCards
{
    self.game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[self createDeck]
                                    numberOfCardsToPlayWith:self.numberOfCardsToPlayWith];
    if (!self.matchModeControl.enabled) self.matchModeControl.enabled = YES;
    [self updateUI];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    if (self.matchModeControl.enabled) self.matchModeControl.enabled = NO;
    NSUInteger chosenButtonIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    [self updateUI];
}

# pragma mark - update UI

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        NSUInteger cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardButtonIndex];
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.isMatched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.score];
    self.statusLabel.text = self.game.status;
}

- (NSString *)titleForCard:(Card *)card
{
    if (CARD_CONTENT_CHEAT) {
        return card.contents;
    } else {
        return card.isChosen ? card.contents : @"";
    }
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    if (CARD_CONTENT_CHEAT) {
        return [UIImage imageNamed:@"cardfront"];
    } else {
        return [UIImage imageNamed:card.chosen ? @"cardfront" : @"cardback"];
    }
}

@end
