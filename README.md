# Social Media Management System

This project sets up a social media database with tables and functionality to manage users, posts, comments, friendships, and likes. The database includes various stored procedures, triggers, and views to support typical social media operations.

## Tables

- **Users**: Stores user information.
- **Posts**: Stores posts made by users.
- **Comments**: Stores comments made on posts.
- **Friendships**: Manages friendships between users.
- **Likes**: Tracks likes on posts.

## Views

- **UserFeed**: Displays a user's feed with posts from their connections.

## Triggers

- **UpdateLikeCount**: Updates the like count on a post when a new like is added.
- **DecreaseLikeCount**: Updates the like count on a post when a like is removed.

## Usage

1. **Create Database**: Run the provided SQL commands to set up the database and tables.
2. **Insert Data**: Insert sample data into the tables.
3. **Test Procedures**: Call stored procedures to test functionalities like sending friend requests, creating posts, and adding comments.
4. **Run Queries**: Execute queries to view data, such as recent posts from friends or mutual friends between users.

## SQL Commands

1. **Create Tables**: Defines schema for Users, Posts, Comments, Friendships, and Likes.
2. **Create View**: UserFeed to show a user's posts from their connections.
3. **Create Triggers**: UpdateLikeCount and DecreaseLikeCount for managing like counts.
4. **Create Procedures**: SendFriendRequest, CreatePost, AddComment, and ModeratePosts for various operations.
5. **Insert Data**: Add sample records to Users, Posts, Comments, Friendships, and Likes.

## Queries

- **User Feed**: `SELECT * FROM UserFeed;`
- **Recent Comments**: `SELECT * FROM Comments WHERE CommentDate > NOW() - INTERVAL 1 DAY;`
- **Mutual Friends**: Query to find mutual friends between two users.
- **Recent Posts from Friends**: Retrieves the most recent posts from friends.

## Created By
Midhun Manoj
