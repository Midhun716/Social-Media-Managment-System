CREATE DATABASE MI;
USE MI;
-- Create Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Posts table
CREATE TABLE Posts (
    PostID INT PRIMARY KEY AUTO_INCREMENT,

    UserID INT NOT NULL,
    PostContent TEXT NOT NULL,
    PostDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LikeCount INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create Comments table
CREATE TABLE Comments (
    CommentID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT NOT NULL,
    UserID INT NOT NULL,
    CommentText TEXT NOT NULL,
    CommentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create Friendships table
CREATE TABLE Friendships (
    FriendshipID INT PRIMARY KEY AUTO_INCREMENT,
    UserID1 INT NOT NULL,
    UserID2 INT NOT NULL,
    FriendshipDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID1) REFERENCES Users(UserID),
    FOREIGN KEY (UserID2) REFERENCES Users(UserID),
    UNIQUE (UserID1, UserID2)
);

-- Create Likes table
CREATE TABLE Likes (
    LikeID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT NOT NULL,
    UserID INT NOT NULL,
    LikeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
SHOW TABLES;
-- Create a view to show a user's feed with posts from their connections
CREATE VIEW UserFeed AS
SELECT DISTINCT
    U.Username,
    P.PostContent,
    P.PostDate,
    P.LikeCount
FROM 
    Users U
JOIN 
    Posts P ON U.UserID = P.UserID
JOIN 
    Friendships F ON (F.UserID1 = U.UserID OR F.UserID2 = U.UserID);




-- Create a trigger to update like count when a new like is added
DELIMITER //
CREATE TRIGGER UpdateLikeCount
AFTER INSERT ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts
    SET LikeCount = LikeCount + 1
    WHERE PostID = NEW.PostID;
END;//
DELIMITER  ;

-- Create a trigger to update like count when a like is removed
DELIMITER //
CREATE TRIGGER DecreaseLikeCount
AFTER DELETE ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts
    SET LikeCount = LikeCount - 1
    WHERE PostID = OLD.PostID;
END;//
DELIMITER ;

-- Procedure for sending a friend request
DELIMITER //
CREATE PROCEDURE SendFriendRequest (
    IN p_UserID1 INT,
    IN p_UserID2 INT
)
BEGIN
    -- Check if the friendship already exists
    IF NOT EXISTS (
        SELECT 1
        FROM Friendships
        WHERE (UserID1 = p_UserID1 AND UserID2 = p_UserID2)
           OR (UserID1 = p_UserID2 AND UserID2 = p_UserID1)
    ) THEN
        -- Insert the friendship if it does not exist
        INSERT INTO Friendships (UserID1, UserID2)
        VALUES (p_UserID1, p_UserID2);
    END IF;
END;//
DELIMITER ;
-- Procedure for creating a new post
DELIMITER //
CREATE PROCEDURE CreatePost (
    IN p_UserID INT,
    IN p_PostContent TEXT
)
BEGIN
    INSERT INTO Posts (UserID, PostContent)
    VALUES (p_UserID, p_PostContent);
END;//
DELIMITER ;

-- Procedure for adding a comment to a post
DELIMITER //
CREATE PROCEDURE AddComment (
    IN p_PostID INT,
    IN p_UserID INT,
    IN p_CommentText TEXT
)
BEGIN
    INSERT INTO Comments (PostID, UserID, CommentText)
    VALUES (p_PostID, p_UserID, p_CommentText);
END;//
DELIMITER ;

-- Cursor to iterate through user posts for content moderation
DELIMITER //
CREATE PROCEDURE ModeratePosts ()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE p_PostID INT;
    DECLARE p_PostContent TEXT;
    DECLARE cur CURSOR FOR SELECT PostID, PostContent FROM Posts;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO p_PostID, p_PostContent;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- Implement moderation logic here, e.g., check for inappropriate content
    END LOOP;
    CLOSE cur;
END;//
DELIMITER ;
-- Inserting values to Users Table
INSERT INTO Users (Username, Email, Password) VALUES ('Alice', 'alice@example.com', 'password123');
INSERT INTO Users (Username, Email, Password) VALUES ('Bob', 'bob@example.com', 'password456');
INSERT INTO Users (Username, Email, Password) VALUES ('Charlie', 'charlie@example.com', 'password789');

-- Inserting values to Posts Table
INSERT INTO Posts (UserID, PostContent) VALUES (1, 'This is Alice\'s first post');
INSERT INTO Posts (UserID, PostContent) VALUES (2, 'This is Bob\'s first post');
INSERT INTO Posts (UserID, PostContent) VALUES (3, 'This is Charlie\'s first post');

-- Inserting values to Comments Table
INSERT INTO Comments (PostID, UserID, CommentText) VALUES (1, 2, 'Nice post, Alice!');
INSERT INTO Comments (PostID, UserID, CommentText) VALUES (2, 3, 'Great post, Bob!');
INSERT INTO Comments (PostID, UserID, CommentText) VALUES (3, 1, 'Interesting post, Charlie!');

-- Inserting values to Friendships Table
INSERT INTO Friendships (UserID1, UserID2) VALUES (1, 2);
INSERT INTO Friendships (UserID1, UserID2) VALUES (1, 3);
INSERT INTO Friendships (UserID1, UserID2) VALUES (2, 3);

-- Inserting values to Likes Table
INSERT INTO Likes (PostID, UserID) VALUES (1, 2);
INSERT INTO Likes (PostID, UserID) VALUES (1, 3);
INSERT INTO Likes (PostID, UserID) VALUES (2, 1);

-- Userfeed VIEW
SELECT * FROM Users;
SELECT * FROM Posts;
SELECT * FROM Friendships;
SELECT *FROM Likes;
SELECT * FROM UserFeed;

-- Test SendFriendRequest Procedure 
CALL SendFriendRequest(1, 3);

-- Test CreatePost Procedure
CALL CreatePost(1, 'Alice\'s second post');

-- Test AddComment Procedure
CALL AddComment(1, 3, 'Another comment on Alice\'s post');

-- Display the number of likes for each post.
SELECT PostID, COUNT(*) AS LikeCount FROM Likes GROUP BY PostID;

-- To check recet comments
SELECT * FROM Comments WHERE CommentDate > NOW() - INTERVAL 1 DAY;
SHOW TABLES;

-- Find mutual friends between two users
SELECT DISTINCT 
    U3.Username AS MutualFriend
FROM 
    Friendships F1
JOIN 
    Friendships F2 ON F1.UserID2 = F2.UserID2
JOIN 
    Users U3 ON F1.UserID2 = U3.UserID
WHERE 
    F1.UserID1 = 1 AND F2.UserID1 = 2;

-- Retrieve the most recent posts from friends
SELECT 
    P.PostID,
    P.PostContent,
    P.PostDate,
    U.Username
FROM 
    Posts P
JOIN 
    Friendships F ON P.UserID = F.UserID2
JOIN 
    Users U ON P.UserID = U.UserID
WHERE 
	F.UserID1 = 1
ORDER BY 
    P.PostDate DESC
LIMIT 10;
