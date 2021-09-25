# streaks_budget

A simple script that updates a budget category in You Need A Budget (YNAB) based on the number of days that a streak has been active in the Streaks iOS app.  The idea is to use this as a motivational tool and 'pay yourself' for not breaking the chain.  If you do break the chain, you lose all your money in the budget category.  I've set this up as a cron job and it updates my "Fun Money" automatically every day.

## Pre-requisites

- An iPhone running the Streaks App
- A Dropbox account with a Personal Access Token
- A YNAB subscription with a Personal Access Token
- Ruby

## Basic Setup

1. Set up a Siri Automation to Export Data in CSV format from the Streaks App for one Streak to a location within Dropbox.
2. Create a constants.rb file based on the template containing the personal access tokens for YNAB and Dropbox, the path to the exported file from the Siri Shortcut, the name of the YNAB budget category you would like to update, and how many dollars you will give yourself per day of the completed streak.
3. Run script.rb using Ruby and watch your budget category update based on whether or not you've kept your streak alive.

## Todo
- [ ] Make it sensitive to the different kinds of Streaks in the Streaks app, it's currently tailored toward negative habits you wish to avoid.  I suspect if you attempt to use it for a positive Habit it's going to calculate an extra day.
- [ ] Add logic to appropriately cut off during month transitions.  Currently, on the first of the month you would be credited with all the money earned for the entire streak, but you would still have that amount left over from the previous month.  It needs to appropriately roll from month to month.

Still working on it.
