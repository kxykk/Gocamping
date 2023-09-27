CREATE TABLE `user` (
  `user_id` integer PRIMARY KEY,
  `email` varchar(255),
  `password` varchar(255),
  `name` varchar(255),
  `user_imageURL` varchar(255),
  `user_imageType` varchar(255),
  `user_imageSize` integer,
  `account_createDate` date,
  `lastLoginDate` date
);

CREATE TABLE `following` (
  `following_id` integer,
  `user_id` integer
);

CREATE TABLE `follower` (
  `follower_id` integer,
  `user_id` integer
);

CREATE TABLE `article` (
  `article_id` integer PRIMARY KEY,
  `user_id` integer,
  `title` varchar(255),
  `article_title_imageURL` varchar(255), 
  `article_title_imageType` varchar(255),  
  `article_title_imageSize` integer,      
  `article_createDate` datetime
);

CREATE TABLE `text` (
  `article_id` integer,
  `text_sortNumber` varchar(255),
  `content` varchar(255)
);

CREATE TABLE `image` (
  `article_id` integer,
  `image_sortNumber` integer,
  `article_imageURL` varchar(255),
  `article_imageType` varchar(255),
  `article_imageSize` integer
);

CREATE TABLE `comment` (
  `article_id` integer,
  `user_id` integer,
  `text` varchar(255)
);

CREATE TABLE `camp` (
  `camp_id` integer PRIMARY KEY,
  `name` varchar(255),
  `city` varchar(255),
  `area` varchar(255),
  `longitube` double,
  `latitube` double,
  `isService` bool,
  `phoneNumber` integer,
  `website` varchar(255),
  `camp_imageURL` varchar(255),
  `camp_imageType` varchar(255),
  `camp_imageSize` integer
);

CREATE TABLE `article_collections` (
  `user_id` integer,
  `article_id` integer
);

ALTER TABLE `following` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `following` ADD FOREIGN KEY (`following_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `follower` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `follower` ADD FOREIGN KEY (`follower_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `article` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `text` ADD FOREIGN KEY (`article_id`) REFERENCES `article` (`article_id`);

ALTER TABLE `image` ADD FOREIGN KEY (`article_id`) REFERENCES `article` (`article_id`);

ALTER TABLE `comment` ADD FOREIGN KEY (`article_id`) REFERENCES `article` (`article_id`);

ALTER TABLE `comment` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `article_collections` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

ALTER TABLE `article_collections` ADD FOREIGN KEY (`article_id`) REFERENCES `article` (`article_id`);
